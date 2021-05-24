/**
 * @file    ADAU1761.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _ADAU1761_H_
#define _ADAU1761_H_

#include "AudioStreamFIFO.h"
#include "ConfigFIFO.h"

typedef struct {
  uint8_t chipAddr;
} adau1761_config_t;

class ADAU1761 {
 private:
  adau1761_config_t mDevConfig;
  AudioStreamFIFO mAudioStreamFifo;
  ConfigFIFO mConfigFifo;

  bool adau1761_chip_config();

 public:
  ADAU1761();
  ~ADAU1761();

  bool Initialize(function<void()> const& audioStreamEmptyCallback);
  void WriteAudioBuffer(audio_buffer_t const& buffer);
};

#endif /* _ADAU1761_H_ */
