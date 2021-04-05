/*****************************************************************************/
/**
 * @file    decimator.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Decimator IP header.
 */
/*****************************************************************************/

#ifndef _DECIMATOR_HPP
#define _DECIMATOR_HPP

#include "fm_global.hpp"

template <uint32_t decimation_T>
class DECIMATOR {
 private:
  uint8_t count = 0;
  sample_t decimated;
  bool valid = false;

 public:
  void operator()(sample_t const& in_sample, sample_t& out, bool& out_valid);
};

// DECIMATOR main algorithm
template <uint32_t decimation_T>
void DECIMATOR<decimation_T>::operator()(sample_t const& in_sample,
                                         sample_t& out,
                                         bool& out_valid) {
  if (count >= decimation_T - 1) {
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

#endif /* _DECIMATOR_HPP */
