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

static DELAY<sample_t, 3> delay_i_inst;
static DELAY<sample_t, 3> delay_q_inst;

static DataWriter writer_fm_demod_test_in("fm_demod_test_in.txt");
static DataWriter writer_fm_demod_test_in_del("fm_demod_test_in_del.txt");
static DataWriter writer_fm_demod_test_out("fm_demod_test_out.txt");

sample_t fm_demodulator(sample_t const& in_i, sample_t const& in_q) {
  writer_fm_demod_test_in.write(in_i);
  writer_fm_demod_test_in.write(in_q);

  // Delay
  sample_t i_sample_del = delay_i_inst(in_i);
  sample_t q_sample_del = delay_q_inst(in_q);

  writer_fm_demod_test_in_del.write(i_sample_del);
  writer_fm_demod_test_in_del.write(q_sample_del);

  // Differentiate
  sample_t i_sample_diff = in_i - i_sample_del;
  sample_t q_sample_diff = in_q - q_sample_del;

  // Demodulate
  sample_t demod_part_a = in_i * q_sample_diff;
  sample_t demod_part_b = in_q * i_sample_diff;

  sample_t fm_demod = demod_part_a - demod_part_b;

  writer_fm_demod_test_out.write(fm_demod);

  return fm_demod;
}
