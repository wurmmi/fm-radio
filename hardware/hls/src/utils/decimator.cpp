/*****************************************************************************/
/**
 * @file    decimator.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Decimator IP implementation.
 */
/*****************************************************************************/

#include "decimator.hpp"

using namespace std;

void decimator(sample_t const& in, sample_t& out, bool& out_valid) {
  static uint8_t count = 0;
  static sample_t decimated;
  static bool valid = false;

  if (count >= osr_rx_c - 1) {
    // Output decimated value
    count     = 0;
    decimated = in;
    valid     = true;
  } else {
    // No output
    count++;
    valid = false;
  }

  out_valid = valid;
  out       = decimated;
}
