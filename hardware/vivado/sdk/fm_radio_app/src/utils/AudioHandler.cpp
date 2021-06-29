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

AudioHandler::AudioHandler()
    : mStreamDMA(XPAR_AXI_DMA_0_DEVICE_ID),
      mIPOutputFifo(XPAR_AXI_FIFO_MM_S1_IP_OUTPUT_DEVICE_ID) {
  mFmRadioIP = nullptr;
  mVolume    = volume_default_c;
  mIsPlaying = false;

  Initialize();
  FillAudioBuffer();
}

AudioHandler::~AudioHandler() {}

bool AudioHandler::Initialize() {
  if (!mAdau1761.Initialize()) {
    return false;
  }

  LOG_DEBUG("Configuring the IPOutput-FIFO ...");
  int status = mIPOutputFifo.Initialize();
  if (!status) {
    LOG_ERROR("could not initialize the IPOutput-FIFO");
    return false;
  }

  status = mIPOutputFifo.SetupInterrupts(
      XPAR_FABRIC_AXI_FIFO_MM_S1_IP_OUTPUT_INTERRUPT_INTR,
      nullptr,
      bind(&AudioHandler::IPOutputFifoFullCallback, this));
  LOG_DEBUG("Done.");

  return true;
}

void AudioHandler::IPOutputFifoFullCallback() {
  LOG_DEBUG("IPOutputFIFO full!");
  auto data = mIPOutputFifo.ReadAll();

  LOG_INFO("read %d data values from IPOutputFIFO", data.size());

  /** TODO: move this into another thread and notify it (or use a DMA)
   *       (Writing a file here in the ISR is bad practise...)
   */
  /** NOTE:
   *    Filename needs to be in short form, so that
   *    the XilFFS (see <ff.h>) driver understands it..
   */
  string filename = mFmRadioIP->GetTypeStr() + ".txt";

  static uint8_t write_counter = 0;
  if (write_counter == 0) {
    const bool overwrite = true;
    bool success         = mSdCardReader.WriteFile(filename, data, overwrite);
    if (!success)
      return;
    write_counter++;
  }
}

void AudioHandler::ResetIPOutputFIFO() {
  mIPOutputFifo.ResetRx();
}

void AudioHandler::SetIP(FMRadioIP* radioIP) {
  if (!radioIP) {
    LOG_ERROR("nullptr");
    return;
  }
  mFmRadioIP = radioIP;
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

  uint32_t* pSource = (uint32_t*)buffer.buffer;
  for (size_t i = 0; i < buffer.size / 4; i++) {
    // Split 32 bit into 2x 16 bit
    int16_t left  = (int16_t)((pSource[i] >> 16) & 0xFFFF);
    int16_t right = (int16_t)((pSource[i] >> 0) & 0xFFFF);

    // Adapt volume
    left  = left * mVolume / 4;
    right = right * mVolume / 4;

    // Combine to 32 bit again
    pSource[i] = ((uint32_t)left << 16) + (uint32_t)right;
  }
}

void AudioHandler::PrintVolumeInfo(string const& limit) {
  string msg = "volume: " + to_string(mVolume) + limit;

  if (mIsPlaying)
    msg += " (STOP and START again to apply)";

  LOG_INFO("%s", msg.c_str());
}

void AudioHandler::VolumeUp() {
  if (!mFmRadioIP) {
    LOG_ERROR("nullptr");
    return;
  }
  if (mFmRadioIP->GetMode() == TMode::FMRADIO) {
    LOG_WARN("volume settings only available in FM_RADIO mode!");
    return;
  }
  string limit = "";
  if (mVolume >= volume_max_c)
    limit = " (MAXIMUM)";
  else
    mVolume++;

  PrintVolumeInfo(limit);
}

void AudioHandler::VolumeDown() {
  if (!mFmRadioIP) {
    LOG_ERROR("nullptr");
    return;
  }
  if (mFmRadioIP->GetMode() == TMode::FMRADIO) {
    LOG_WARN("volume settings only available in FM_RADIO mode!");
    return;
  }

  string limit = "";
  if (mVolume <= volume_min_c)
    limit = " (MINIMUM)";
  else
    mVolume--;

  PrintVolumeInfo(limit);
}

void AudioHandler::PlayFile(std::string const& filename) {
  bool success = mSdCardReader.LoadFile(filename);
  if (!success)
    return;

  if (!mFmRadioIP) {
    LOG_ERROR("nullptr");
    return;
  }
  if (mFmRadioIP->GetMode() == TMode::PASSTHROUGH)
    ApplyVolume();
  auto buffer = mSdCardReader.GetBuffer();
  mStreamDMA.TransmitBlob(buffer);
  mIsPlaying = true;
  LOG_INFO("DMA playing in endless loop ...");
}

void AudioHandler::Stop() {
  mStreamDMA.Stop();
  mIsPlaying = false;
  LOG_INFO("DMA stopped.");
}

void AudioHandler::ShowAvailableFiles() {
  mSdCardReader.MountSDCard();
  mSdCardReader.DiscoverFiles();
  mSdCardReader.PrintAvailableFilenames();
}
