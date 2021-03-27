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
--       03/23/2021  08:30 - 13:00    4:30 h
--                   14:00 - 17:30    3:30 h
--
*/

// TODO: implement top-level with AXI stream

#include "fm_receiver.hpp"

#include <iostream>

#include "../tb/helper/DataWriter.hpp"
#include "channel_decoder.hpp"
#include "utils/decimator.hpp"
#include "utils/fm_demodulator.hpp"

using namespace std;

void fm_receiver(sample_t const& in_i,
                 sample_t const& in_q,
                 sample_t& out_audio_L,
                 sample_t& out_audio_R) {
  // ------------------------------------------------------
  // FM Demodulator
  // ------------------------------------------------------

  sample_t fm_demod = fm_demodulator(in_i, in_q);

  // ------------------------------------------------------
  // Decimator
  // ------------------------------------------------------

  sample_t fm_channel_data;
  bool fm_channel_data_valid;
  decimator(fm_demod, fm_channel_data, fm_channel_data_valid);

  if (fm_channel_data_valid) {
    // ------------------------------------------------------
    // Channel decoder
    // ------------------------------------------------------

    sample_t audio_L;
    sample_t audio_R;
    channel_decoder(fm_channel_data, audio_L, audio_R);

    // ------------------------------------------------------
    // Output
    // ------------------------------------------------------

    out_audio_L = audio_L;
    out_audio_R = audio_R;
  }

  // ------------------------------------------------------
  // Debug
  // ------------------------------------------------------

#ifndef __SYNTHESIS__
  static DataWriter writer_data_out_fm_demod("data_out_fm_demod.txt");
  writer_data_out_fm_demod.write(fm_demod);
#endif
}
