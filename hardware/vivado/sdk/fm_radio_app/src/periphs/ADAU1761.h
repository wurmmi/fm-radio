/**
 * @file    ADAU1761.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _ADAU1761_H_
#define _ADAU1761_H_

#include <functional>

#include "ADAU1761_hw.h"
#include "ConfigFIFO.h"

class ADAU1761 {
 private:
  ConfigFIFO mConfigFifo;

  bool adau1761_chip_config();

 public:
  ADAU1761();
  ~ADAU1761();

  bool Initialize();
};

#endif /* _ADAU1761_H_ */
