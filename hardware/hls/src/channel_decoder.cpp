/*****************************************************************************/
/**
 * @file    channel_decoder.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver IP implementation.
 */
/*****************************************************************************/

#include <iostream>

#include "../tb/helper/DataWriter.hpp"
#include "filter_coeff_headers/filter_bp_pilot.h"
#include "fm_receiver.hpp"
#include "utils/fir.hpp"

using namespace std;

// TODO: get this from a global header file
const ap_fixed<4, 4> pilot_scale_factor_c = 6;

void channel_decoder(sample_t const& in_sample,
                     sample_t& out_audio_L,
                     sample_t& out_audio_R) {
  // ------------------------------------------------------
  // Recover pilot
  // ------------------------------------------------------
  static FIR<coeff_t, sample_t, acc_t, filter_bp_pilot_num_coeffs_c>
      fir_pilot_inst;

  sample_t pilot = pilot_scale_factor_c *
                   fir_pilot_inst(in_sample, filter_bp_pilot_coeffs_c);

  // ------------------------------------------------------
  // Debug
  // ------------------------------------------------------

  static DataWriter writer_data_out_pilot("data_out_rx_pilot.txt");
  writer_data_out_pilot.write(pilot);
}
