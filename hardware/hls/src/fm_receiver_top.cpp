/*****************************************************************************/
/**
 * @file    fm_receiver_top.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver top-level wrapper implementation.
 */
/*****************************************************************************/

/*
-- TIME LOGGING
--
-- (1) FM receiver top (AXI stream interface) implementation
--       03/30/2021  15:30 - 19:00    2:00 h
--
*/

#include "fm_receiver_top.hpp"

#include <iostream>

#include "../tb/helper/DataWriter.hpp"
#include "fm_receiver.hpp"

using namespace std;

void fm_receiver_top(iq_sample_t const& sample_in,
                     sample_t& out_audio_L,
                     sample_t& out_audio_R) {
#pragma HLS INTERFACE ap_vld port = out_audio_L
#pragma HLS INTERFACE ap_vld port = out_audio_R
#pragma HLS INTERFACE axis port   = sample_in
#pragma HLS DATA_PACK variable    = sample_in

  // Split IQ samples
  sample_t in_i = sample_in.i;
  sample_t in_q = sample_in.q;

  // ------------------------------------------------------
  // FM Receiver IP
  // ------------------------------------------------------

  sample_t audio_L;
  sample_t audio_R;
  fm_receiver(in_i, in_q, audio_L, audio_R);

  // ------------------------------------------------------
  // Output
  // ------------------------------------------------------

  out_audio_L = audio_L;
  out_audio_R = audio_R;
}
