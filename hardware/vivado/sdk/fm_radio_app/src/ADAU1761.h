/**
 * @file    ADAU1761.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _ADAU1761_H_
#define _ADAU1761_H_

#include <functional>

#include "AudioStreamFIFO.h"
#include "ConfigFIFO.h"

class ADAU1761 {
 private:
  AudioStreamFIFO mAudioStreamFifo;
  ConfigFIFO mConfigFifo;

  bool adau1761_chip_config();

 public:
  ADAU1761();
  ~ADAU1761();

  bool Initialize(std::function<void()> const& audioStreamEmptyCallback);
  void WriteAudioBuffer(audio_buffer_t const& buffer);
};

#endif /* _ADAU1761_H_ */
