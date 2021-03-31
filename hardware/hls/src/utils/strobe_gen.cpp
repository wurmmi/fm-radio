/*****************************************************************************/
/**
 * @file    strobe_gen.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Strobe Generator IP implementation.
 */
/*****************************************************************************/

#include "strobe_gen.hpp"

bool strobe_gen() {
  static uint8_t count = 0;

  if (count >= num_wait_cycles_c - 1) {
    count = 0;
    return true;
  } else {
    count++;
  }
  return false;
}
