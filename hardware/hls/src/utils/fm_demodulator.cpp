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

static DataWriter writer_fm_demod_test_in("fm_demod_test_in.txt");
static DataWriter writer_fm_demod_test_in_del("fm_demod_test_in_del.txt");
static DataWriter writer_fm_demod_test_out("fm_demod_test_out.txt");

sample_t fm_demodulator(iq_sample_t const& iq) {
  writer_fm_demod_test_in.write(iq.i);
  writer_fm_demod_test_in.write(iq.q);

  // Delay
  iq_sample_t sample_del = delay_inst(iq);

  writer_fm_demod_test_in_del.write(sample_del.i);
  writer_fm_demod_test_in_del.write(sample_del.q);

  // Differentiate
  sample_t i_sample_diff = iq.i - sample_del.i;
  sample_t q_sample_diff = iq.q - sample_del.q;

  // Demodulate
  sample_t demod_part_a = iq.i * q_sample_diff;
  sample_t demod_part_b = iq.q * i_sample_diff;

  sample_t fm_demod = demod_part_a - demod_part_b;

  writer_fm_demod_test_out.write(fm_demod);

  return fm_demod;
}
