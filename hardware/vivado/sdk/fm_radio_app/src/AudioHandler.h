/**
 * @file    AudioHandler.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _AUDIOHANDLER_H_
#define _AUDIOHANDLER_H_

#include <array>

#include "ADAU1761.h"
#include "AudioStreamDMA.h"
#include "FIFO.h"
#include "SDCardReader.h"

class AudioHandler {
 private:
  ADAU1761 mAdau1761;
  audio_buffer_t mAudioBuffer;
  SDCardReader mSdCardReader;
  AudioStreamDMA mStreamDMA;
  uint16_t mVolume;

  uint16_t const volume_default_c = 4;
  uint16_t const volume_max_c     = 4;
  uint16_t const volume_min_c     = 1;

  bool Initialize();
  void FillAudioBuffer();
  void ApplyVolume();
  void AudioStreamEmptyCallback();

 public:
  AudioHandler();
  ~AudioHandler();

  void VolumeUp();
  void VolumeDown();
  void PlayFile(std::string const& filename);
  void Stop();
  void ShowAvailableFiles();
};

#endif /* _AUDIOHANDLER_H_ */
