/**
 * @file    AudioStreamDMA.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "AudioStreamDMA.h"

#include <iostream>

using namespace std;

AudioStreamDMA::AudioStreamDMA(uint32_t device_id) : mDeviceId(device_id) {}

AudioStreamDMA::~AudioStreamDMA() {}

bool AudioStreamDMA::Initialize() {
  int status = XAxiDma_CfgInitialize(&mDev, XAxiDma_LookupConfig(mDeviceId));
  if (status != XST_SUCCESS) {
    cout << "Failed to initialize DMA\n" << endl;
    return false;
  }

  if (!XAxiDma_HasSg(&mDev))
    cout << "Device configured as simple mode\n" << endl;
  else
    cout << "Device has Scatter-Gather engine mode\n" << endl;

  XAxiDma_BdRing *txRingPtr = XAxiDma_GetTxRing(&mDev);

  mDmaWritten = false;

  // Disable all TX interrupts before TxBD space setup
  XAxiDma_BdRingIntDisable(txRingPtr, XAXIDMA_IRQ_ALL_MASK);

  // Setup TxBD space
  u32 bd_count = XAxiDma_BdRingCntCalc(XAXIDMA_BD_MINIMUM_ALIGNMENT,
                                       (u32)sizeof(mBdBuffer));

  status = XAxiDma_BdRingCreate(txRingPtr,
                                (UINTPTR)mBdBuffer[0],
                                (UINTPTR)mBdBuffer[0],
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
