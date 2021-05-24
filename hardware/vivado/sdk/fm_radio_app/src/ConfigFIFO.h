/**
 * @file    ConfigFIFO.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _CONFIGFIFO_H_
#define _CONFIGFIFO_H_

#include "FIFO.h"

#define FIFO_CHIP_ADDR 0

class ConfigFIFO : public FIFO {
 private:
 public:
  ConfigFIFO(uint32_t device_id);
  ~ConfigFIFO();

  uint8_t read(uint16_t addr);
  void write(uint16_t addr, uint8_t value);
};

#endif /* _CONFIGFIFO_H_ */
