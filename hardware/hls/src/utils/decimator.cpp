/*****************************************************************************/
/**
 * @file    decimator.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Decimator IP implementation.
 */
/*****************************************************************************/

#include "decimator.hpp"

using namespace std;

void decimator(sample_t const& in_sample, sample_t& out, bool& out_valid) {
  static uint8_t count = 0;
  static sample_t decimated;
  static bool valid = false;

  if (count >= OSR_RX - 1) {
    // Output decimated value
    count     = 0;
    decimated = in_sample;
    valid     = true;
  } else {
    // No output
    count++;
    valid = false;
  }

  out_valid = valid;
  out       = decimated;
}
