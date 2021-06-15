/**
 * @file    AudioHandler.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "AudioHandler.h"

#include <cassert>
#include <cmath>
#include <iostream>

#include "log.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

using namespace std;

AudioHandler::AudioHandler(FMRadioIP* radioIP)
    : mStreamDMA(XPAR_AXI_DMA_0_DEVICE_ID) {
  assert(radioIP);
  mFmRadioIP = radioIP;
  mVolume    = volume_default_c;

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

void AudioHandler::ApplyVolume() {
  auto buffer = mSdCardReader.GetBuffer();
  if (buffer.buffer == nullptr) {
    LOG_ERROR("no file loaded yet");
    return;
  }

  // Apply volume (and swap left and right channel)
  uint32_t* pSource = (uint32_t*)buffer.buffer;
  for (size_t i = 0; i < buffer.size / 4; i++) {
    // Split 32 bit into 2x 16 bit
    int16_t left  = (int16_t)((pSource[i] >> 16) & 0xFFFF);
    int16_t right = (int16_t)((pSource[i] >> 0) & 0xFFFF);

    // Adapt volume
    left  = left * mVolume / 4;
    right = right * mVolume / 4;

    // Combine to 32 bit again
    pSource[i] = ((uint32_t)right << 16) + (uint32_t)left;
  }
}

void AudioHandler::VolumeUp() {
  if (mFmRadioIP->GetMode() == TMode::FMRADIO) {
    LOG_ERROR("volume settings only available in FM_RADIO mode!");
    return;
  }

  if (mVolume >= volume_max_c)
    LOG_INFO("maximum volume reached");
  else
    mVolume++;
  LOG_INFO("volume: %d", mVolume);
}

void AudioHandler::VolumeDown() {
  if (mFmRadioIP->GetMode() == TMode::FMRADIO) {
    LOG_ERROR("volume settings only available in FM_RADIO mode!");
    return;
  }

  if (mVolume <= volume_min_c)
    LOG_INFO("minimum volume reached");
  else
    mVolume--;
  LOG_INFO("volume: %d", mVolume);
}

void AudioHandler::PlayFile(std::string const& filename) {
  mSdCardReader.LoadFile(filename);
  if (mFmRadioIP->GetMode() == TMode::PASSTHROUGH)
    ApplyVolume();
  auto buffer = mSdCardReader.GetBuffer();
  mStreamDMA.TransmitBlob(buffer);
  LOG_INFO("DMA playing in endless loop ...");
}

void AudioHandler::Stop() {
  mStreamDMA.Stop();
  LOG_INFO("DMA stopped.");
}

void AudioHandler::ShowAvailableFiles() {
  mSdCardReader.MountSDCard();
  mSdCardReader.DiscoverFiles();
  mSdCardReader.PrintAvailableFilenames();
}
