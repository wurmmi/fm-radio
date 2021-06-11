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
-- (3) Audio decimation
--       04/05/2021  17:00 - 18:00    1:00 h
*/

#include "fm_receiver.hpp"

#include <iostream>

#include "../tb/helper/DataWriter.hpp"
#include "channel_decoder.hpp"
#include "utils/fm_demodulator.hpp"

using namespace std;

void fm_receiver(hls::stream<iq_sample_t>& iq_in, audio_sample_t& out_audio) {
  // ------------------------------------------------------
  // FM Demodulator (incl. decimator)
  // ------------------------------------------------------

  hls::stream<sample_t> fm_channel_data;
#pragma HLS STREAM depth = OSR_AUDIO variable = fm_channel_data

  /** NOTE:
   *  This loop performs decimation by N.
   *  --> Processing N samples. Only the last sample is passed on
   *      to the next processing steps.
   */
  sample_t fm_demod;
  for (uint32_t i = 0; i < OSR_AUDIO; i++) {
    for (uint32_t k = 0; k < OSR_RX; k++) {
      iq_sample_t iq = iq_in.read();
      fm_demod       = fm_demodulator(iq);

      if (k == OSR_RX - 1) {
        fm_channel_data.write(fm_demod);
      }

      // ------------------------------------------------------
      // Debug
      // ------------------------------------------------------
#ifndef __SYNTHESIS__
      static DataWriter writer_data_out_fm_demod("data_out_fm_demod.txt");
      writer_data_out_fm_demod.write(fm_demod);
#endif
    }
  }

  // ------------------------------------------------------
  // Channel decoder
  // ------------------------------------------------------

  audio_sample_t audio_sample;
  channel_decoder(fm_channel_data, audio_sample);

  // ------------------------------------------------------
  // Output
  // ------------------------------------------------------

  out_audio = audio_sample;
}
