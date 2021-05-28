/**
 * @file    AudioStreamDMA.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _AUDIOSTREAMDMA_H_
#define _AUDIOSTREAMDMA_H_

#include <xaxidma.h>
#include <xscugic.h>

// Size of the buffer which holds the DMA Buffer Descriptors (BDs)
#define DMA_BD_BUFFER_SIZE        32
#define DMA_NUM_BDS_PER_PKT       2
#define DMA_COALESCING_COUNT      1    // valid range 1..255
#define DMA_DELAY_TIMER_COUNT     100  // valid range 0..255
#define DMA_RESET_TIMEOUT_COUNTER 10000

typedef struct {
  uint8_t* buffer;
  uint32_t bufferSize;
} DMABuffer;

class AudioStreamDMA {
 private:
  XScuGic mIntCtrl;
  uint8_t const mIntCtrlId = XPAR_FABRIC_AXIDMA_0_VEC_ID;

  XAxiDma mDev;
  XAxiDma_Bd mBdBuffer[DMA_BD_BUFFER_SIZE]
      __attribute__((aligned(XAXIDMA_BD_MINIMUM_ALIGNMENT)));
  uint8_t mDeviceId;
  bool mDmaWritten;
  int mErrorState;
  DMABuffer mDataBuffer;

  void Transmit(DMABuffer const& buffer,
                bool isFirst,
                bool isLast,
                XAxiDma_Bd* bd_ptr);

  bool TxSetup();
  bool InterruptSetup();
  static void TxIRQCallback(void* context);
  void TxIRQHandler();
  void TxDoneCallback();

 public:
  AudioStreamDMA(uint32_t device_id);
  ~AudioStreamDMA();

  bool Initialize(DMABuffer const& dataBuffer);
  void TransmitBlob();
};

#endif /* _AUDIOSTREAMDMA_H_ */
