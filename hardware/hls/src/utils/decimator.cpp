/*****************************************************************************/
/**
 * @file    decimator.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Decimator IP implementation.
 */
/*****************************************************************************/

#include "decimator.hpp"

using namespace std;

sample_t decimator(sample_t const& in) {
  static uint8_t count = 0;
  static sample_t decimated;

  if (count >= osr_rx_c - 1) {
    decimated = in;
    count     = 0;
  } else {
    count++;
  }

  return decimated;
}
