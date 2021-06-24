/**
 * @file    IPOutputFIFO.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _IPOUTPUTFIFO_H_
#define _IPOUTPUTFIFO_H_

#include "FIFO.h"

// TODO: can this be retrieved from the generated driver includes?
#define FIFO_CHIP_ADDR 0

class IPOutputFIFO : public FIFO {
 private:
 public:
  IPOutputFIFO(uint32_t device_id);
  ~IPOutputFIFO();

  uint8_t read(uint16_t addr);
};

#endif /* _IPOUTPUTFIFO_H_ */
