/*****************************************************************************/
/**
 * @file    fm_receiver_hls.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver top-level wrapper implementation.
 */
/*****************************************************************************/

/*
clang-format off
-- TIME LOGGING
--
-- (1) FM receiver top (AXI stream interface) implementation
--       03/30/2021  15:30 - 20:00    4:30 h
--       03/31/2021  14:30 - 18:00    3:30 h  trying to find out how/when top-level
--                                            function is called with clk cycles
--
-- (2) Debug Error with Bitwidth
--       05/21/2021  14:00 - 19:00    5:00 h  Not sure what the error was.
--                                            Parallel delay for I/Q didn't work.
--                                            The order of every 2nd data value was wrong.
--                                            Using a single delay fixed it.
--
-- (3) LED control
--       05/28/2021  20:00 - 22:00    2:00 h  Implementation of AXI4-lite HLS interface,
--                                            with firmware support
--
--       05/28/2021  22:00 - 01:30    3:30 h  Fixing issue with auto-generated driver.
--       05/29/2021  14:00 - 20:00    6:00 h  It did not get imported into the SDK.
--                                            Problem was that HLS project and top-level
--                                            did not have the same name....
--
-- (4) Build information status register
--       05/31/2021  22:00 - 00:00    2:00 h  Begin with interface
--       06/08/2021  20:00 - 00:00    4:00 h  Trying to find out how to use a char-array on Axilite.
--       06/09/2021  22:00 - 00:00    2:00 h  -''-
--                                            Using an ap_uint<> now instead of a char-array, which
--                                            is the most efficient way.
--
--
--
clang-format on
*/

#include "fm_receiver_hls.hpp"

#include <iostream>

#include "../tb/helper/DataWriter.hpp"
#include "fm_receiver.hpp"

using namespace std;

/** Select implementation variant
 *  NOTE: Selection is mutually exclusive - only enable one at a time!
 */
#define IMPL_DATA_FORWARDING_ONLY 0
#define IMPL_FM_RADIO             1

#ifndef GIT_HASH
#warning GIT_HASH is undefined!
#define GIT_HASH undefined
#endif

#ifndef BUILD_TIME
#warning BUILD_TIME is undefined!
#define BUILD_TIME 4711
#endif

#define STRING2(x) #x
#define STRING(x)  STRING2(x)

void fm_receiver_hls(hls::stream<iq_sample_t>& iq_in,
                     hls::stream<audio_sample_t>& audio_out,
                     uint8_t led_ctrl,
                     status_git_hash_t* status_git_hash,
                     status_build_time_t* status_build_time,
                     uint8_t* led_out) {
#pragma HLS INTERFACE ap_ctrl_hs port = return

#pragma HLS INTERFACE axis port = iq_in
#pragma HLS DATA_PACK variable  = iq_in

/** NOTE: this does not have any effect on the generated HDL ... */
#pragma HLS STREAM depth = 32 variable = iq_in

#pragma HLS INTERFACE axis port = audio_out
#pragma HLS DATA_PACK variable  = audio_out

#pragma HLS INTERFACE s_axilite port = status_git_hash bundle = CONFIG
#pragma HLS INTERFACE s_axilite port = status_build_time bundle = CONFIG
#pragma HLS INTERFACE s_axilite port = led_ctrl bundle = CONFIG

#pragma HLS INTERFACE ap_none port = status_git_hash
#pragma HLS INTERFACE ap_none port = status_build_time
#pragma HLS INTERFACE ap_none port = led_out

#if IMPL_DATA_FORWARDING_ONLY == 1
  /*----------- Forwarding test --------------*/
  iq_sample_t fw_iq_in = iq_in.read();

  audio_sample_t fw_iq_out = {fw_iq_in.i, fw_iq_in.q};

  audio_out.write(fw_iq_out);
#endif /* IMPL_DATA_FORWARDING_ONLY */

  /*-------------- Other testing -------------*/

  // NOTE: This is used to determine how often this function is called.
  //       The toggle flag can be compared against the input clock.
  static bool toggle = false;
  toggle             = !toggle;

  /*----------- AXILITE Interface ------------*/
  static const status_git_hash_t status_git_hash_c     = STRING(GIT_HASH);
  static const status_build_time_t status_build_time_c = STRING(BUILD_TIME);

  *status_git_hash   = status_git_hash_c;
  *status_build_time = status_build_time_c;

  *led_out = led_ctrl | (((uint8_t)toggle << 2));

#if IMPL_FM_RADIO == 1
  /*---------------- FM radio ----------------*/

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
#endif /* IMPL_FM_RADIO */
}
