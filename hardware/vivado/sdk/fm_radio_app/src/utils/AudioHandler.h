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
#include "FMRadioIP_HLS.h"
#include "IPOutputFIFO.h"
#include "SDCardReader.h"

class AudioHandler {
 private:
  ADAU1761 mAdau1761;
  audio_buffer_t mAudioBuffer;
  SDCardReader mSdCardReader;
  AudioStreamDMA mStreamDMA;
  FMRadioIP* mFmRadioIP;
  IPOutputFIFO mIPOutputFifo;
  uint16_t mVolume;
  bool mIsPlaying;

  uint16_t const volume_default_c = 4;
  uint16_t const volume_max_c     = 4;
  uint16_t const volume_min_c     = 1;

  bool Initialize();
  void FillAudioBuffer();
  void ApplyVolume();
  void PrintVolumeInfo(std::string const& limit);
  void SwapLeftAndRight();

  void IPOutputFifoFullCallback();

 public:
  AudioHandler();
  ~AudioHandler();

  void SetIP(FMRadioIP* ip);

  void VolumeUp();
  void VolumeDown();
  void PlayFile(std::string const& filename);
  void Stop();
  void ShowAvailableFiles();
};

#endif /* _AUDIOHANDLER_H_ */
