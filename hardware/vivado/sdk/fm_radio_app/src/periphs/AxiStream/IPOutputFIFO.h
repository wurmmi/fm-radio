/**
 * @file    IPOutputFIFO.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _IPOUTPUTFIFO_H_
#define _IPOUTPUTFIFO_H_

#include <vector>

#include "FIFO.h"

class IPOutputFIFO : public FIFO {
 private:
 public:
  IPOutputFIFO(uint32_t device_id);
  ~IPOutputFIFO();

  std::vector<uint32_t> ReadAll();
  void ResetRx();
};

#endif /* _IPOUTPUTFIFO_H_ */
