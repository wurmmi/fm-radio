/**
 * @file    AudioHandler.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _AUDIOHANDLER_H_
#define _AUDIOHANDLER_H_

#include <array>

#include "ADAU1761.h"
#include "FIFO.h"

class AudioHandler {
 private:
  ADAU1761 mAdau1761;
  audio_buffer_t mAudioBuffer;

  void InitAudioBuffer();
  void AudioStreamEmptyCallback();

 public:
  AudioHandler();
  ~AudioHandler();

  bool Initialize();
};

#endif /* _AUDIOHANDLER_H_ */
