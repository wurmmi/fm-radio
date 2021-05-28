/**
 * @file    AudioHandler.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "AudioHandler.h"

#include <cmath>
#include <iostream>

#include "log.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

using namespace std;

AudioHandler::AudioHandler() {
  Initialize();
  FillAudioBuffer();
}

AudioHandler::~AudioHandler() {}

bool AudioHandler::Initialize() {
  if (!mAdau1761.Initialize()) {
    return false;
  }
  LOG_DEBUG("AudioHandler hardware initialization OKAY");
  return true;
}

void AudioHandler::FillAudioBuffer() {
  const double amp = 16384;
  int16_t left;
  int16_t right;
  for (size_t i = 0; i < mAudioBuffer.size(); i++) {
    left  = (int16_t)(cos((double)i / FIFO_NUM_SAMPLES * 2 * M_PI) * amp);
    right = (int16_t)(sin((double)i / FIFO_NUM_SAMPLES * 2 * M_PI) * amp);
    mAudioBuffer[i] = {(uint16_t)left, (uint16_t)right};
  }
}
