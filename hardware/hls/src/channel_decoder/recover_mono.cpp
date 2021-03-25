/*****************************************************************************/
/**
 * @file    recover_mono.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Recover Mono IP implementation.
 */
/*****************************************************************************/

#include "recover_mono.hpp"

#include "filter_coeff_headers/filter_bp_lrdiff.h"
#include "filter_coeff_headers/filter_lp_mono.h"
#include "utils/delay.hpp"
#include "utils/fir.hpp"

using namespace std;

static DELAY<sample_t, filter_bp_lrdiff_grpdelay_c> delay_inst;

sample_t recover_mono(sample_t const& in_sample) {
  // Filter mono audio
  static FIR<coeff_t, sample_t, acc_t, filter_lp_mono_num_coeffs_c>
      fir_mono_inst;

  sample_t mono = fir_mono_inst(in_sample, filter_lp_mono_coeffs_c);

  // Delay
  sample_t mono_delayed = delay_inst(mono);

  return mono_delayed;
}
