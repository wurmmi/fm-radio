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
--       03/22/2021  11:00 - xxxxx    xxxx h
--
*/

#include "fm_receiver.hpp"

#include <iostream>

#include "../tb/helper/DataWriter.hpp"
#include "filter_coeff_headers/filter_bp_lrdiff.h"
#include "filter_coeff_headers/filter_bp_pilot.h"
#include "utils/fir.hpp"

using namespace std;

// TODO: get this from a global header file
const ap_fixed<4, 4> pilot_scale_factor_c = 6;

sample_t fm_receiver(sample_t in) {
  // Recover pilot
  static FIR<coeff_t, sample_t, acc_t, filter_bp_pilot_num_coeffs_c>
      fir_pilot_inst;

  sample_t pilot =
      pilot_scale_factor_c * fir_pilot_inst(in, filter_bp_pilot_coeffs_c);

  static DataWriter writer_data_out_pilot("data_out_rx_pilot.txt");
  writer_data_out_pilot.write(pilot);

  // Recover lrdiff
  static FIR<coeff_t, sample_t, acc_t, filter_bp_lrdiff_num_coeffs_c>
      fir_lrdiff_inst;
  sample_t lrdiff = fir_lrdiff_inst(in, filter_bp_lrdiff_coeffs_c);

  return pilot;
}
