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
#define DMA_BD_BUFFER_SIZE        400  // NUMBER_OF_BDS_TO_TRANSFER
#define DMA_COALESCING_COUNT      400
#define DMA_DELAY_TIMER_COUNT     100
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

  void Transmit(DMABuffer const& buffer, uint32_t n_repeats);

  bool TxSetup();
  bool InterruptSetup();
  static void TxIRQCallback(void* context);
  void TxIRQHandler();
  void TxDoneCallback();

 public:
  AudioStreamDMA(uint32_t device_id);
  ~AudioStreamDMA();

  bool Initialize();
  void TransmitBlob(DMABuffer const& buffer);
};

#endif /* _AUDIOSTREAMDMA_H_ */
