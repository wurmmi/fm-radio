/**
 * @file    AudioStreamDMA.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _AUDIOSTREAMDMA_H_
#define _AUDIOSTREAMDMA_H_

#include <xaxidma.h>

// Size of the buffer which holds the DMA Buffer Descriptors (BDs)
#define DMA_BUFFER_SIZE 4000

typedef struct DMABuffer {
  uint8_t* buffer;
  uint32_t bufferSize;
};

class AudioStreamDMA {
 private:
  XAxiDma mDev;
  XAxiDma_Bd mBdBuffer[DMA_BUFFER_SIZE]
      __attribute__((aligned(XAXIDMA_BD_MINIMUM_ALIGNMENT)));
  uint8_t mDeviceId;
  bool mDmaWritten;

  void Transmit(DMABuffer const& buffer, uint32_t n_repeats);

 public:
  AudioStreamDMA(uint32_t device_id);
  ~AudioStreamDMA();

  bool Initialize();
  void TransmitBlob(DMABuffer const& buffer);
};

#endif /* _AUDIOSTREAMDMA_H_ */
