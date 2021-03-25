/*****************************************************************************/
/**
 * @file    recover_carriers.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Recover Carriers IP implementation.
 */
/*****************************************************************************/

#include "recover_carriers.hpp"

#include "../tb/helper/DataWriter.hpp"
#include "filter_coeff_headers/filter_bp_pilot.h"
#include "utils/fir.hpp"

using namespace std;

void recover_carriers(sample_t const& in_sample,
                      sample_t& out_carrier_38k,
                      sample_t& out_carrier_57k) {
  // Recover and amplify pilot
  static FIR<coeff_t, sample_t, acc_t, filter_bp_pilot_num_coeffs_c>
      fir_pilot_inst;

  sample_t pilot = pilot_scale_factor_c *
                   fir_pilot_inst(in_sample, filter_bp_pilot_coeffs_c);

  // Create 38kHz carrier
  sample_t carrier_38k = pilot * pilot * 2 - carrier_38k_offset_c;

  // ------------------------------------------------------
  // Output
  // ------------------------------------------------------

  out_carrier_38k = carrier_38k;
  out_carrier_57k = 0;

  // ------------------------------------------------------
  // Debug
  // ------------------------------------------------------

  static DataWriter writer_data_out_pilot("data_out_pilot.txt");
  writer_data_out_pilot.write(pilot);
}
