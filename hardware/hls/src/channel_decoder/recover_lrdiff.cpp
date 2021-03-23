/*****************************************************************************/
/**
 * @file    recover_lrdiff.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Recover LR Diff IP implementation.
 */
/*****************************************************************************/

#include "recover_lrdiff.hpp"

#include "filter_coeff_headers/filter_bp_lrdiff.h"
#include "filter_coeff_headers/filter_lp_mono.h"
#include "utils/fir.hpp"

using namespace std;

sample_t recover_lrdiff(sample_t const& in_sample, sample_t& in_carrier_38k) {
  // Bandpass 23..38kHz
  static FIR<coeff_t, sample_t, acc_t, filter_bp_lrdiff_num_coeffs_c>
      fir_lrdiff_inst;

  sample_t lrdiff_bpfilt =
      fir_lrdiff_inst(in_sample, filter_bp_lrdiff_coeffs_c);

  // Modulate down to baseband
  sample_t lrdiff_mod_bb = in_carrier_38k * lrdiff_bpfilt * 2;

  // Lowpass
  static FIR<coeff_t, sample_t, acc_t, filter_lp_mono_num_coeffs_c>
      fir_mono_inst;
  sample_t lrdiff = fir_mono_inst(lrdiff_mod_bb, filter_lp_mono_coeffs_c);

  // Output
  return lrdiff;
}
