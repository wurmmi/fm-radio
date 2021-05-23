/**
 * @file    adau1761.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _ADAU1761_H_
#define _ADAU1761_H_

#include "xllfifo.h"
#include "xscugic.h"

typedef struct {
  XLlFifo fifo_spi;
  XLlFifo fifo_i2s;
  XScuGic intCtrl;
  uint8_t chipAddr;
  int wordSize;
  uint32_t *buffer;
  uint32_t buffersize;
} adau1761_config_t;

class adau1761 {
 private:
  adau1761_config_t mDevConfig;

  uint8_t read(uint16_t addr);
  void write(uint16_t addr, uint8_t value);

  bool init_fifos();

 public:
  adau1761();
  ~adau1761();

  bool initialize();
};

#endif /* _ADAU1761_H_ */
