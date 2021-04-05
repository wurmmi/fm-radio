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
--       03/31/2021  14:30 - 18:00    3:30 h  trying to find out how/when
--                                            top-level function is called
--                                            with clk cycles
--
*/

#include "fm_receiver_top.hpp"

#include <iostream>

#include "../tb/helper/DataWriter.hpp"
#include "fm_receiver.hpp"
#include "utils/strobe_gen.hpp"

using namespace std;

void fm_receiver_top(hls::stream<iq_sample_t>& iq_in,
                     hls::stream<audio_sample_t>& audio_out) {
#pragma HLS INTERFACE ap_ctrl_none port = return

#pragma HLS INTERFACE axis port = audio_out
#pragma HLS DATA_PACK variable  = audio_out

#pragma HLS INTERFACE axis port = iq_in
#pragma HLS DATA_PACK variable  = iq_in

  // NOTE: This is used to determine how often this function is called.
  //       The toggle flag can be compared against the input clock.
  // TODO: remove this debug toggle
  static bool toggle = false;
  toggle             = !toggle;

  if (strobe_gen()) {
    // ------------------------------------------------------
    // Read input and split IQ samples
    // ------------------------------------------------------

    iq_sample_t in = iq_in.read();
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

    audio_sample_t audio_sample = {audio_L, audio_R};
    audio_out.write(audio_sample);
  }
}
