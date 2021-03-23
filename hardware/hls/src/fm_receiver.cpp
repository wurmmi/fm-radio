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
--       03/19/2021  09:30 - 18:00    8:30 h
--       03/22/2021  09:00 - 11:00    2:00 h
--
-- (2) FM receiver implementation
--       03/22/2021  11:00 - 13:00    2:00 h
--                   14:00 - 16:00    2:00 h
--       03/23/2021  08:30 - xxxxxxxxxxxxx h
--
*/

#include "fm_receiver.hpp"

#include <iostream>

#include "../tb/helper/DataWriter.hpp"
#include "filter_coeff_headers/filter_bp_lrdiff.h"
#include "filter_coeff_headers/filter_bp_pilot.h"
#include "fm_demodulator.hpp"
#include "utils/delay.hpp"
#include "utils/fir.hpp"

using namespace std;

// TODO: get this from a global header file
const ap_fixed<4, 4> pilot_scale_factor_c = 6;

void fm_receiver(sample_t const& in_i,
                 sample_t const& in_q,
                 sample_t& audio_L,
                 sample_t& audio_R) {
  // ------------------------------------------------------
  // FM Demodulator
  // ------------------------------------------------------

  sample_t fm_demod = fm_demodulator(in_i, in_q);

  // Recover pilot
  static FIR<coeff_t, sample_t, acc_t, filter_bp_pilot_num_coeffs_c>
      fir_pilot_inst;

  sample_t pilot =
      pilot_scale_factor_c * fir_pilot_inst(fm_demod, filter_bp_pilot_coeffs_c);

  static DataWriter writer_data_out_pilot("data_out_rx_pilot.txt");
  writer_data_out_pilot.write(pilot);

  // ------------------------------------------------------
  // Output
  // ------------------------------------------------------
  audio_L = pilot;
  audio_R = 0;

  // ------------------------------------------------------
  // Debug
  // ------------------------------------------------------
  static DataWriter writer_data_out_fm_demod("data_out_fm_demod.txt");
  writer_data_out_fm_demod.write(fm_demod);
}
