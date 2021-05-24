/**
 * @file    AudioStreamFIFO.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "AudioStreamFIFO.h"

#include <iostream>

using namespace std;

AudioStreamFIFO::AudioStreamFIFO(uint32_t device_id) : FIFO(device_id) {}

AudioStreamFIFO::~AudioStreamFIFO() {}

void AudioStreamFIFO::write(audio_sample_t const& sample) {
  while (!XLlFifo_iTxVacancy(&mDev)) {
    // Don't do this in an interrupt routine...
    // printf("I2S FIFO full. Waiting ... \n");
  }
  XLlFifo_TxPutWord(&mDev, ((u32)left << 16) | (u32)right);
  XLlFifo_iTxSetLen(&mDev, 1 * FIFO_STREAM_WORDSIZE);
}
