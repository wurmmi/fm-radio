/*****************************************************************************/
/**
 * @file    fm_demodulator.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Demodulator IP implementation.
 */
/*****************************************************************************/

#include "fm_demodulator.hpp"

#include <iostream>

#include "../tb/helper/DataWriter.hpp"
#include "utils/delay.hpp"

using namespace std;

static DELAY<iq_sample_t, 3> delay_inst;

sample_t fm_demodulator(iq_sample_t const& iq) {
  // Delay
  iq_sample_t sample_del = delay_inst(iq);

  // Differentiate
  sample_t i_sample_diff = iq.i - sample_del.i;
  sample_t q_sample_diff = iq.q - sample_del.q;

  // Demodulate
  sample_t demod_part_a = iq.i * q_sample_diff;
  sample_t demod_part_b = iq.q * i_sample_diff;

  sample_t fm_demod = demod_part_a - demod_part_b;

  return fm_demod;
}
