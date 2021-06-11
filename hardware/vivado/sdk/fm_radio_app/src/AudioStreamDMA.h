/**
 * @file    AudioStreamDMA.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _AUDIOSTREAMDMA_H_
#define _AUDIOSTREAMDMA_H_

#include <xaxidma.h>
#include <xscugic.h>

#include "FileReader.h"

// Size of the buffer which holds the DMA Buffer Descriptors (BDs)
#define DMA_NUM_BD_MAX            32
#define DMA_DELAY_TIMER_COUNT     100  // valid range 0..255
#define DMA_RESET_TIMEOUT_COUNTER 10000

class AudioStreamDMA {
 private:
  XScuGic* mIntCtrl;
  uint8_t const mIntCtrlId = XPAR_FABRIC_AXIDMA_0_VEC_ID;

  XAxiDma mDev;
  XAxiDma_Bd mBdBuffer[DMA_NUM_BD_MAX]
      __attribute__((aligned(XAXIDMA_BD_MINIMUM_ALIGNMENT)));
  uint8_t mDeviceId;
  int mErrorState;
  bool mIsInitialized;
  DMABuffer mDataBuffer;
  uint32_t mNumRequiredBDs;

  void Transmit(DMABuffer const& buffer,
                bool isFirst,
                bool isLast,
                XAxiDma_Bd* bd_ptr);

  bool Initialize();
  bool TxSetup();
  bool InterruptSetup();
  static void TxIRQCallback(void* context);
  void TxIRQHandler();
  void TxDoneCallback();

 public:
  AudioStreamDMA(uint32_t device_id);
  ~AudioStreamDMA();

  void TransmitBlob(DMABuffer const& dataBuffer);
  void Stop();
};

#endif /* _AUDIOSTREAMDMA_H_ */
