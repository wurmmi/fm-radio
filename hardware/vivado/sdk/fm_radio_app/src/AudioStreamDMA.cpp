/**
 * @file    AudioStreamDMA.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "AudioStreamDMA.h"

#include <cassert>
#include <iostream>

#include "log.h"

using namespace std;

AudioStreamDMA::AudioStreamDMA(uint32_t device_id) : mDeviceId(device_id) {}

AudioStreamDMA::~AudioStreamDMA() {}

void AudioStreamDMA::TxDoneCallback() {
  cout << "################## DMA Tx DONE" << endl;
}

bool AudioStreamDMA::TxSetup() {
  XAxiDma_BdRing* txRingPtr = XAxiDma_GetTxRing(&mDev);

  // Disable all TX interrupts before TxBD space setup
  XAxiDma_BdRingIntDisable(txRingPtr, XAXIDMA_IRQ_ALL_MASK);

  // Setup Tx BD space (check how many BDs can fit into mBdBuffer region)
  uint32_t bd_count = XAxiDma_BdRingCntCalc(XAXIDMA_BD_MINIMUM_ALIGNMENT,
                                            (uint32_t)sizeof(mBdBuffer));
  if (bd_count != DMA_BD_BUFFER_SIZE) {
    LOG_ERROR("something went wrong here - sizes don't match");
    return false;
  }

  int status = XAxiDma_BdRingCreate(txRingPtr,
                                    (UINTPTR)&mBdBuffer[0],
                                    (UINTPTR)&mBdBuffer[0],
                                    XAXIDMA_BD_MINIMUM_ALIGNMENT,
                                    bd_count);
  if (status != XST_SUCCESS) {
    printf("Failed create BD ring\n");
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
    printf("Failed to clone BDs\n");
    return false;
  }

  /*
   * Set the coalescing threshold.

   * We set the coalescing threshold to be the total number of packets.
   * The receive side will only get one completion interrupt per cyclic
   * transfer.
   *
   * If you would like to have multiple interrupts to happen, change
   * the DMA_COALESCING_COUNT to be a smaller value.
   */
  status = XAxiDma_BdRingSetCoalesce(
      txRingPtr, DMA_COALESCING_COUNT, DMA_DELAY_TIMER_COUNT);
  if (status != XST_SUCCESS) {
    xil_printf("Failed set coalescing %d/%d\n",
               DMA_COALESCING_COUNT,
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
    printf("Failed bd start\n");
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
      XScuGic_CfgInitialize(&mIntCtrl, IntcConfig, IntcConfig->CpuBaseAddress);
  if (status != XST_SUCCESS) {
    LOG_ERROR("failed XScuGic_CfgInitialize()");
    return false;
  }

  XScuGic_SetPriorityTriggerType(&mIntCtrl, mIntCtrlId, 0xA0, 0x3);

  /*
   * Connect the device driver handler that will be called when an
   * interrupt for the device occurs. The handler performs the specific
   * interrupt processing for the device.
   */
  status = XScuGic_Connect(
      &mIntCtrl, mIntCtrlId, (Xil_InterruptHandler)TxIRQCallback, this);
  if (status != XST_SUCCESS) {
    LOG_ERROR("failed XScuGic_Connect()");
    return false;
  }

  XScuGic_Enable(&mIntCtrl, mIntCtrlId);

  /* Enable interrupts from the hardware */
  Xil_ExceptionInit();
  Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                               (Xil_ExceptionHandler)XScuGic_InterruptHandler,
                               (void*)&mIntCtrl);

  Xil_ExceptionEnable();

  return true;
}

bool AudioStreamDMA::Initialize(DMABuffer const& dataBuffer) {
  mDataBuffer = dataBuffer;

  cout << "Initialize DMA ..." << endl;
  int status = XAxiDma_CfgInitialize(&mDev, XAxiDma_LookupConfig(mDeviceId));
  if (status != XST_SUCCESS) {
    cout << "Failed to initialize DMA\n" << endl;
    return false;
  }

  if (!XAxiDma_HasSg(&mDev)) {
    cerr << "ERROR: Device configured as simple mode" << endl;
    return false;
  } else {
    cout << "Device has Scatter-Gather engine mode" << endl;
  }

  mDmaWritten = false;

  bool ret = TxSetup();
  if (!ret) {
    LOG_ERROR("TxSetup failed");
    return false;
  }

  ret = InterruptSetup();
  if (!ret) {
    LOG_ERROR("InterruptSetup failed");
    return false;
  }

  cout << "Done." << endl;
  return true;
}

void AudioStreamDMA::TransmitBlob() {
  /** TODO: rewrite this function according to example code */

  cout << "TransmitBlob: bufferSize = " << mDataBuffer.bufferSize << endl;

  XAxiDma_BdRing* txRingPtr = XAxiDma_GetTxRing(&mDev);

  uint32_t n_samples_remain = mDataBuffer.bufferSize;
  uint32_t max_block_size   = txRingPtr->MaxTransferLen / 4;
  uint32_t* p_block         = (uint32_t*)mDataBuffer.buffer;

  cout << "n_samples_remain = " << n_samples_remain << endl;
  cout << "max_block_size   = " << max_block_size << endl;

  uint32_t transmit_count = 0;
  bool isFirst            = true;
  bool isLast             = false;
  XAxiDma_Bd* bd_ptr      = nullptr;

  while (n_samples_remain > 0) {
    uint32_t nTransfer = max_block_size;
    if (n_samples_remain < max_block_size) {
      nTransfer = n_samples_remain;
      isLast    = true;
    }
    Transmit({(uint8_t*)p_block, nTransfer}, isFirst, isLast, bd_ptr);
    n_samples_remain -= nTransfer;
    p_block += nTransfer;

    cout << "transmit_count = " << transmit_count << endl;
    transmit_count++;
    isFirst = false;
  }

  // Give the BD to hardware
  int status = XAxiDma_BdRingToHw(txRingPtr, transmit_count, bd_ptr);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Failed to hw");
  }

  cout << "Done." << endl;
  cout << "transmit_count = " << transmit_count << endl;
}

/**
 * @brief Blocks can have a maximum size of "txRingPtr->MaxTransferLen"
 * (around 8 MBytes)
 */
void AudioStreamDMA::Transmit(DMABuffer const& buffer,
                              bool isFirst,
                              bool isLast,
                              XAxiDma_Bd* bd_ptr) {
  XAxiDma_BdRing* txRingPtr = XAxiDma_GetTxRing(&mDev);
  if (isFirst)
    cout << "first" << endl;
  if (isLast)
    cout << "last" << endl;

  // Free the processed BDs from previous run.
  // adau1761_dmaFreeProcessedBDs(pDevice);

  // Flush the SrcBuffer before the DMA transfer, in case the Data Cache is
  // enabled
  Xil_DCacheFlushRange((uint32_t)buffer.buffer,
                       buffer.bufferSize * sizeof(uint32_t));

  // XAxiDma_Bd* bd_ptr;
  uint32_t const num_of_bds_to_alloc_c = 1;
  int status = XAxiDma_BdRingAlloc(txRingPtr, num_of_bds_to_alloc_c, &bd_ptr);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Failed bd alloc");
    return;
  }

  XAxiDma_Bd* bd_cur_ptr = bd_ptr;
  status = XAxiDma_BdSetBufAddr(bd_cur_ptr, (UINTPTR)buffer.buffer);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Tx set buffer addr failed");
    return;
  }

  status = XAxiDma_BdSetLength(bd_cur_ptr,
                               buffer.bufferSize * sizeof(uint32_t),
                               txRingPtr->MaxTransferLen);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Tx set length failed");
    return;
  }

  uint32_t CrBits = 0;
  if (isFirst) {
    CrBits |= XAXIDMA_BD_CTRL_TXSOF_MASK;  // First BD
  }
  if (isLast) {
    CrBits |= XAXIDMA_BD_CTRL_TXEOF_MASK;  // Last BD
  }
  XAxiDma_BdSetCtrl(bd_cur_ptr, CrBits);
  XAxiDma_BdSetId(bd_cur_ptr,
                  (UINTPTR)buffer.buffer); /** TODO: advance this pointer */

  bd_cur_ptr = (XAxiDma_Bd*)XAxiDma_BdRingNext(txRingPtr, bd_cur_ptr);

  //  // Give the BD to hardware
  //  status = XAxiDma_BdRingToHw(txRingPtr, num_of_bds_to_alloc_c, bd_ptr);
  //  if (status != XST_SUCCESS) {
  //    LOG_ERROR("Failed to hw");
  //  }

  mDmaWritten = true;
}
