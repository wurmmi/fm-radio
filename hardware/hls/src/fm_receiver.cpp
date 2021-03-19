/*****************************************************************************/
/**
 * @file    fm_receiver.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver IP implementation.
 */
/*****************************************************************************/

/*
-- TIME LOGGING
--
-- (1) FIR filter implementation
--       03/18/2021  17:00 - 19:00    2:00 h
--       03/19/2021  09:30 -          x:xx h
--
-- (2) FM receiver implementation
--
*/

#include "fm_receiver.hpp"

#include <iostream>

#include "utils/fir.hpp"

using namespace std;

sample_t fm_receiver(sample_t in) {
  // FIR filter pilot
  sample_t pilot = fir_filter(in);

  return pilot;
}
