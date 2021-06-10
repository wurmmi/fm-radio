/**
 * @file    AudioStreamDMA.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "AudioStreamDMA.h"

#include <FreeRTOS.h>

#include <cassert>
#include <cmath>
#include <iostream>

#include "log.h"

using namespace std;

// Interrupt controller of FreeRTOS
extern XScuGic xInterruptController;

AudioStreamDMA::AudioStreamDMA(uint32_t device_id) : mDeviceId(device_id) {
  mDataBuffer.buffer = nullptr;
  mDataBuffer.size   = 0;

  /* Use the FreeRTOS interrupt controller here.
   * Otherwise we would crash/overwrite all the interrupt settings of the OS.
   */
  mIntCtrl = &xInterruptController;

  bool ret = Initialize();
  if (!ret) {
    LOG_ERROR("Error in DMA initialization");
    return;
  }
}

AudioStreamDMA::~AudioStreamDMA() {}

void AudioStreamDMA::TxDoneCallback() {
  LOG_INFO("TxDoneCallback: DMA Tx DONE");
}

bool AudioStreamDMA::TxSetup() {
  /* Calculate number of required BDs */
  XAxiDma_BdRing* txRingPtr = XAxiDma_GetTxRing(&mDev);
  uint32_t max_block_size   = txRingPtr->MaxTransferLen;
  mNumRequiredBDs           = ceil((float)mDataBuffer.size / max_block_size);

  LOG_DEBUG("bufferSize      = %ld", mDataBuffer.size);
  LOG_DEBUG("max_block_size  = %ld", max_block_size);
  LOG_DEBUG("mNumRequiredBDs = %ld", mNumRequiredBDs);

  if (mNumRequiredBDs > DMA_NUM_BD_MAX) {
    LOG_ERROR("Cannot allocate %ld BDs! Maximum is %d.",
              mNumRequiredBDs,
              DMA_NUM_BD_MAX);

    return false;
  }

  // Disable all TX interrupts before Tx BD space setup
  XAxiDma_BdRingIntDisable(txRingPtr, XAXIDMA_IRQ_ALL_MASK);

  // Setup empty Tx BD space
  int status = XAxiDma_BdRingCreate(txRingPtr,
                                    (UINTPTR)&mBdBuffer[0],
                                    (UINTPTR)&mBdBuffer[0],
                                    XAXIDMA_BD_MINIMUM_ALIGNMENT,
                                    mNumRequiredBDs);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Failed create BD ring");
    return false;
  }

  /**
   *  Create a template and set all BDs to be the same as the
   *  template. The sender has to set up the BDs as needed.
   */
  XAxiDma_Bd BdTemplate;
  XAxiDma_BdClear(&BdTemplate);
  status = XAxiDma_BdRingClone(txRingPtr, &BdTemplate);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Failed to clone BDs");
    return false;
  }

  /**
   * Set the coalescing threshold.

   * We set the coalescing threshold to be the total number of BDs.
   * Therefore, the we will only get one completion interrupt per cyclic
   * transfer.
   *
   * To have multiple interrupts per cyclic transfer, set the
   * DMA_COALESCING_COUNT to a smaller value.
   */
  uint32_t coalescing_count = mNumRequiredBDs;
  status                    = XAxiDma_BdRingSetCoalesce(
      txRingPtr, coalescing_count, DMA_DELAY_TIMER_COUNT);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Failed set coalescing %ld/%d",
              coalescing_count,
              DMA_DELAY_TIMER_COUNT);
    return XST_FAILURE;
  }

  /* Enable Cyclic DMA mode */
  XAxiDma_BdRingEnableCyclicDMA(txRingPtr);
  XAxiDma_SelectCyclicMode(&mDev, XAXIDMA_DMA_TO_DEVICE, 1);

  /* Enable all TX interrupts */
  XAxiDma_BdRingIntEnable(txRingPtr, XAXIDMA_IRQ_ALL_MASK);

  /* Start the TX channel */
  status = XAxiDma_BdRingStart(txRingPtr);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Failed BdRingStart");
  }

  return true;
}

/** This is the DMA TX Interrupt handler function.
 *
 * It gets the interrupt status from the hardware, acknowledges it,
 * and if any error happens, it resets the hardware. Otherwise, if a
 * completion interrupt presents, then it calls the callback function.
 */
void AudioStreamDMA::TxIRQHandler() {
  XAxiDma_BdRing* txRingPtr = XAxiDma_GetTxRing(&mDev);

  /* Read pending interrupts */
  uint32_t IrqStatus = XAxiDma_BdRingGetIrq(txRingPtr);

  /* Acknowledge pending interrupts */
  XAxiDma_BdRingAckIrq(txRingPtr, IrqStatus);

  /* If no interrupt is asserted, we do not do anything
   */
  if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK)) {
    return;
  }

  /*
   * If error interrupt is asserted, raise error flag, reset the
   * hardware to recover from the error, and return with no further
   * processing.
   */
  if ((IrqStatus & XAXIDMA_IRQ_ERROR_MASK)) {
    XAxiDma_BdRingDumpRegs(txRingPtr);

    mErrorState = 1;

    int timeOut = DMA_RESET_TIMEOUT_COUNTER;
    XAxiDma_Reset(&mDev);
    while (timeOut) {
      if (XAxiDma_ResetIsDone(&mDev)) {
        break;
      }
      timeOut--;
    }
    return;
  }

  /*
   * If Transmit done interrupt is asserted, call TX call back function
   * to handle the processed BDs and raise the according flag
   */
  if ((IrqStatus & (XAXIDMA_IRQ_DELAY_MASK | XAXIDMA_IRQ_IOC_MASK))) {
    TxDoneCallback();
  }
}

void AudioStreamDMA::TxIRQCallback(void* context) {
  static_cast<AudioStreamDMA*>(context)->TxIRQHandler();
}

bool AudioStreamDMA::InterruptSetup() {
  /* Initialize the interrupt controller driver so that it is ready to use. */
  XScuGic_Config* IntcConfig =
      XScuGic_LookupConfig(XPAR_SCUGIC_SINGLE_DEVICE_ID);
  if (IntcConfig == nullptr) {
    LOG_ERROR("failed XScuGic_LookupConfig()");
    return false;
  }

  int status =
      XScuGic_CfgInitialize(mIntCtrl, IntcConfig, IntcConfig->CpuBaseAddress);
  if (status != XST_SUCCESS) {
    LOG_ERROR("failed XScuGic_CfgInitialize()");
    return false;
  }

  XScuGic_SetPriorityTriggerType(mIntCtrl, mIntCtrlId, 0xA0, 0x3);

  /*
   * Connect the device driver handler that will be called when an
   * interrupt for the device occurs. The handler performs the specific
   * interrupt processing for the device.
   */
  status = XScuGic_Connect(
      mIntCtrl, mIntCtrlId, (Xil_InterruptHandler)TxIRQCallback, this);
  if (status != XST_SUCCESS) {
    LOG_ERROR("failed XScuGic_Connect()");
    return false;
  }

  XScuGic_Enable(mIntCtrl, mIntCtrlId);

  /* Enable interrupts from the hardware */
  Xil_ExceptionInit();
  Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                               (Xil_ExceptionHandler)XScuGic_InterruptHandler,
                               (void*)mIntCtrl);

  Xil_ExceptionEnable();

  return true;
}

bool AudioStreamDMA::Initialize() {
  LOG_DEBUG("Initialize DMA ...");
  int status = XAxiDma_CfgInitialize(&mDev, XAxiDma_LookupConfig(mDeviceId));
  if (status != XST_SUCCESS) {
    LOG_ERROR("Failed to initialize DMA");
    return false;
  }

  if (!XAxiDma_HasSg(&mDev)) {
    LOG_ERROR("Device configured as simple mode");
    return false;
  } else {
    LOG_DEBUG("Device has Scatter-Gather engine mode");
  }

  bool ret = InterruptSetup();
  if (!ret) {
    LOG_ERROR("InterruptSetup failed");
    return false;
  }

  LOG_DEBUG("Done.");
  return true;
}

void AudioStreamDMA::TransmitBlob(DMABuffer const& dataBuffer) {
  mDataBuffer = dataBuffer;

  bool ret = TxSetup();
  if (!ret) {
    LOG_ERROR("TxSetup failed");
    return;
  }

  XAxiDma_BdRing* txRingPtr = XAxiDma_GetTxRing(&mDev);
  if (mDataBuffer.size > txRingPtr->MaxTransferLen) {
    LOG_ERROR("BufferSize is larger than maximum transfer length!");
    return;
  }
  LOG_DEBUG("TransmitBlob: bufferSize = %ld", mDataBuffer.size);

  /* Flush the buffers before the DMA transfer, in case the Data Cache is
   * enabled */
  Xil_DCacheFlushRange((uint32_t)mDataBuffer.buffer, mDataBuffer.size);

  XAxiDma_Bd* bd_ptr;
  int status = XAxiDma_BdRingAlloc(txRingPtr, mNumRequiredBDs, &bd_ptr);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Failed bd alloc");
    return;
  }

  /* Create and fill the BDs with information */
  UINTPTR p_block         = (UINTPTR)mDataBuffer.buffer;
  uint32_t n_bytes_remain = mDataBuffer.size;
  XAxiDma_Bd* bd_ptr_cur  = bd_ptr;
  uint32_t transmit_count = 0;
  bool isFirst            = true;
  bool isLast             = false;
  uint32_t max_block_size = txRingPtr->MaxTransferLen;

  LOG_DEBUG("n_bytes_remain  = %ld", n_bytes_remain);

  uint32_t n_byte_to_transfer = max_block_size;
  for (uint8_t i = 0; i < mNumRequiredBDs; i++) {
    // Calculate bytes for current block
    n_byte_to_transfer = max_block_size;
    if (n_bytes_remain < max_block_size) {
      n_byte_to_transfer = n_bytes_remain;
      isLast             = true;
    }

    DMABuffer buffer_cur = {(uint8_t*)p_block, n_byte_to_transfer};
    Transmit(buffer_cur, isFirst, isLast, bd_ptr_cur);

    n_bytes_remain -= n_byte_to_transfer;
    p_block += n_byte_to_transfer;
    bd_ptr_cur = (XAxiDma_Bd*)XAxiDma_BdRingNext(txRingPtr, bd_ptr_cur);

    LOG_DEBUG("transmit_count = %ld", transmit_count);
    transmit_count++;
    isFirst = false;
  }

  // Give the BD to hardware
  status = XAxiDma_BdRingToHw(txRingPtr, mNumRequiredBDs, bd_ptr);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Failed to hw");
  }

  LOG_DEBUG("Done.");
}

/**
 * @brief Blocks can have a maximum size of "txRingPtr->MaxTransferLen"
 *        (around 8 MBytes)
 */
void AudioStreamDMA::Transmit(DMABuffer const& buffer_cur,
                              bool isFirst,
                              bool isLast,
                              XAxiDma_Bd* bd_ptr_cur) {
  int status = XAxiDma_BdSetBufAddr(bd_ptr_cur, (UINTPTR)buffer_cur.buffer);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Tx set buffer addr failed");
    return;
  }

  XAxiDma_BdRing* txRingPtr = XAxiDma_GetTxRing(&mDev);

  status = XAxiDma_BdSetLength(
      bd_ptr_cur, buffer_cur.size, txRingPtr->MaxTransferLen);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Tx set length failed");
    return;
  }

  uint32_t CrBits = 0;
  /** NOTE: Only using one BD per transfer.
   *        Thus the current BD needs to have both bits set.
   *        This may be changed in the future.
   */
  isFirst = true;
  isLast  = true;

  if (isFirst) {
    LOG_DEBUG("first BD");
    CrBits |= XAXIDMA_BD_CTRL_TXSOF_MASK;  // First BD
  }
  if (isLast) {
    LOG_DEBUG("last BD");
    CrBits |= XAXIDMA_BD_CTRL_TXEOF_MASK;  // Last BD
  }

  XAxiDma_BdSetCtrl(bd_ptr_cur, CrBits);
  XAxiDma_BdSetId(bd_ptr_cur, (UINTPTR)buffer_cur.buffer);
}

void AudioStreamDMA::Stop() {
  XAxiDma_Reset(&mDev);
}
