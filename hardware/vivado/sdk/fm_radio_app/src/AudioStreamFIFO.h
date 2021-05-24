/**
 * @file    AudioStreamFIFO.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _AUDIOSTREAMFIFO_H_
#define _AUDIOSTREAMFIFO_H_

#include "FIFO.h"

class AudioStreamFIFO : public FIFO {
 private:
 public:
  AudioStreamFIFO(uint32_t device_id);
  ~AudioStreamFIFO();

  void write(audio_sample_t const& sample);
};

#endif /* _AUDIOSTREAMFIFO_H_ */
