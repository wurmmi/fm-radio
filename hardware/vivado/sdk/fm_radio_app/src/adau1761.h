/**
 * @file    adau1761.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _ADAU1761_H_
#define _ADAU1761_H_

#include <xscugic.h>

#include <array>

#include "FifoHandler.h"

#define NUM_FIFO_SAMPLES 128

typedef struct {
  uint16_t left;
  uint16_t right;
} audio_sample_t;

typedef struct {
  XLlFifo fifo_spi;
  XLlFifo fifo_i2s;
  XScuGic irqCtrl;
  uint8_t chipAddr;
  uint8_t wordSize;
  std::array<audio_sample_t, NUM_FIFO_SAMPLES> fifo_buffer;
} adau1761_config_t;

class adau1761 {
 private:
  adau1761_config_t mDevConfig;
  FifoHandler mAudioStreamFifo;
  FifoHandler mConfigFifo;

  uint8_t read_spi(uint16_t addr);
  void write_spi(uint16_t addr, uint8_t value);
  void write_i2s(uint16_t left, uint16_t right);

  void init_audio_buffer();
  bool init_adau1761();
  static void irq_handler_fifo_callback(void* data);
  void write_buffer_to_fifo();
  bool setup_fifo_interrupts();

 public:
  adau1761();
  ~adau1761();

  bool Initialize();
};

#endif /* _ADAU1761_H_ */
