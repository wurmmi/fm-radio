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
--       03/30/2021  15:30 - 20:00    4:30 h
--       03/31/2021  14:30 - xx:xx    x:xx h
--
*/

#include "fm_receiver_top.hpp"

#include <iostream>

#include "../tb/helper/DataWriter.hpp"
#include "fm_receiver.hpp"
#include "utils/strobe_gen.hpp"

using namespace std;

void fm_receiver_top(hls::stream<iq_sample_t>& sample_in,
                     sample_t& out_audio_L,
                     sample_t& out_audio_R) {
#pragma HLS INTERFACE ap_vld port = out_audio_L
#pragma HLS INTERFACE ap_vld port = out_audio_R
#pragma HLS INTERFACE axis port   = sample_in
#pragma HLS DATA_PACK variable    = sample_in

  static bool toggle = false;

  toggle = !toggle;

  if (strobe_gen()) {
    // ------------------------------------------------------
    // Read input and split IQ samples
    // ------------------------------------------------------

    iq_sample_t in = sample_in.read();
    sample_t in_i  = in.i;
    sample_t in_q  = in.q;

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
}
