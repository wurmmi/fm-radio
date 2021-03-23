/*****************************************************************************/
/**
 * @file    fm_demodulator.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Demodulator IP implementation.
 */
/*****************************************************************************/

#include "fm_demodulator.hpp"

#include <iostream>

#include "utils/delay.hpp"

using namespace std;

sample_t fm_demodulator(sample_t in_i, sample_t in_q) {
  // Delay
  static DELAY<sample_t, 3> delay_i_inst;
  static DELAY<sample_t, 3> delay_q_inst;

  sample_t i_sample_del = delay_i_inst(0);
  sample_t q_sample_del = delay_q_inst(in_q);

  // Differentiate
  sample_t i_sample_diff = in_i - i_sample_del;
  sample_t q_sample_diff = in_q - q_sample_del;

  // Demodulate
  sample_t demod_part_a = in_i * q_sample_diff;
  sample_t demod_part_b = in_q * i_sample_diff;

  sample_t fm_demod = demod_part_a - demod_part_b;
  // sample_t fm_demod = 0;

  return fm_demod;
}
