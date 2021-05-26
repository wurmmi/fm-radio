/**
 * @file    AudioStreamDMA.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "AudioStreamDMA.h"

#include <iostream>

#include "log.h"

using namespace std;

AudioStreamDMA::AudioStreamDMA(uint32_t device_id) : mDeviceId(device_id) {}

AudioStreamDMA::~AudioStreamDMA() {}

bool AudioStreamDMA::Initialize() {
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

  XAxiDma_BdRing* txRingPtr = XAxiDma_GetTxRing(&mDev);

  mDmaWritten = false;

  // Disable all TX interrupts before TxBD space setup
  XAxiDma_BdRingIntDisable(txRingPtr, XAXIDMA_IRQ_ALL_MASK);

  // Setup TxBD space
  uint32_t bd_count = XAxiDma_BdRingCntCalc(XAXIDMA_BD_MINIMUM_ALIGNMENT,
                                            (uint32_t)sizeof(mBdBuffer));

  status = XAxiDma_BdRingCreate(txRingPtr,
                                (UINTPTR)&mBdBuffer[0],
                                (UINTPTR)&mBdBuffer[0],
                                XAXIDMA_BD_MINIMUM_ALIGNMENT,
                                bd_count);
  if (status != XST_SUCCESS) {
    printf("Failed create BD ring\n");
    return false;
  }

  // Like the RxBD space, we create a template and set all BDs to be the
  // same as the template. The sender has to set up the BDs as needed.
  XAxiDma_Bd BdTemplate;
  XAxiDma_BdClear(&BdTemplate);
  status = XAxiDma_BdRingClone(txRingPtr, &BdTemplate);
  if (status != XST_SUCCESS) {
    printf("Failed to clone BDs\n");
    return false;
  }

  // Start the TX channel
  status = XAxiDma_BdRingStart(txRingPtr);
  // status = XAxiDma_StartBdRingHw(txRingPtr);
  if (status != XST_SUCCESS) {
    printf("Failed bd start\n");
  }

  return true;
}

void AudioStreamDMA::TransmitBlob(DMABuffer const& buffer) {
  cout << "TransmitBlob: bufferSize = " << buffer.bufferSize << endl;

  XAxiDma_BdRing* txRingPtr = XAxiDma_GetTxRing(&mDev);

  uint32_t n_samples_remain = buffer.bufferSize;
  uint32_t max_block_size   = txRingPtr->MaxTransferLen / 4;
  uint32_t* p_block         = (uint32_t*)buffer.buffer;

  while (n_samples_remain > 0) {
    uint32_t nTransfer = max_block_size;
    if (n_samples_remain < max_block_size)
      nTransfer = n_samples_remain;

    Transmit({(uint8_t*)p_block, nTransfer}, 1);
    n_samples_remain -= nTransfer;
    p_block += nTransfer;
  }
}

/**
 * @brief Blocks can have a maximum size of "txRingPtr->MaxTransferLen" (around
 *        8 MBytes)
 */
void AudioStreamDMA::Transmit(DMABuffer const& buffer, uint32_t n_repeats) {
  XAxiDma_BdRing* txRingPtr = XAxiDma_GetTxRing(&mDev);

  // Free the processed BDs from previous run.
  // adau1761_dmaFreeProcessedBDs(pDevice);

  // Flush the SrcBuffer before the DMA transfer, in case the Data Cache is
  // enabled
  Xil_DCacheFlushRange((uint32_t)buffer.buffer,
                       buffer.bufferSize * sizeof(uint32_t));

  XAxiDma_Bd* bd_ptr = nullptr;
  int status         = XAxiDma_BdRingAlloc(txRingPtr, n_repeats, &bd_ptr);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Failed bd alloc");
    return;
  }

  XAxiDma_Bd* bd_cur_ptr = bd_ptr;
  for (uint32_t i = 0; i < n_repeats; ++i) {
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
    if (i == 0) {
      CrBits |= XAXIDMA_BD_CTRL_TXSOF_MASK;  // First BD
    }
    if (i == n_repeats - 1) {
      CrBits |= XAXIDMA_BD_CTRL_TXEOF_MASK;  // Last BD
    }
    XAxiDma_BdSetCtrl(bd_cur_ptr, CrBits);

    XAxiDma_BdSetId(bd_cur_ptr, (UINTPTR)buffer.buffer);

    bd_cur_ptr = (XAxiDma_Bd*)XAxiDma_BdRingNext(txRingPtr, bd_cur_ptr);
  }

  // Give the BD to hardware
  status = XAxiDma_BdRingToHw(txRingPtr, n_repeats, bd_ptr);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Failed to hw");
  }

  mDmaWritten = true;
}
