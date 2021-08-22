/*****************************************************************************/
/**
 * @file    channel_decoder.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver IP implementation.
 */
/*****************************************************************************/

#include "channel_decoder.hpp"

#include <iostream>

#include "../tb/helper/DataWriter.hpp"
#include "channel_decoder/recover_carriers.hpp"
#include "channel_decoder/recover_lrdiff.hpp"
#include "channel_decoder/recover_mono.hpp"
#include "channel_decoder/separate_lr_audio.hpp"
#include "fm_receiver.hpp"

using namespace std;

audio_sample_t channel_decoder(hls::stream<sample_t>& in_sample) {
  sample_t carrier_38k;
  sample_t carrier_57k;
  sample_t audio_mono;
  sample_t audio_lrdiff;

  /** NOTE:
   *  This loop performs decimation by OSR_AUDIO.
   *  --> Processing OSR_AUDIO samples. Only the last respective
   *      sample is passed on to the next processing step.
   */
  for (uint32_t i = 0; i < OSR_AUDIO; i++) {
    sample_t sample = in_sample.read();

    // ------------------------------------------------------
    // Recover carriers
    // ------------------------------------------------------
    recover_carriers(sample, carrier_38k, carrier_57k);

    // ------------------------------------------------------
    // Recover mono audio
    // ------------------------------------------------------
    audio_mono = recover_mono(sample);

    // ------------------------------------------------------
    // Recover LR diff audio
    // ------------------------------------------------------
    audio_lrdiff = recover_lrdiff(sample, carrier_38k);

    // ------------------------------------------------------
    // Debug
    // ------------------------------------------------------
#ifndef __SYNTHESIS__
    static DataWriter writer_data_out_fm_channel_data(
        "data_out_fm_channel_data.txt");
    writer_data_out_fm_channel_data.write(sample);

    static DataWriter writer_data_out_carrier_38k("data_out_carrier_38k.txt");
    writer_data_out_carrier_38k.write(carrier_38k);
#endif
  }

  // ------------------------------------------------------
  // Separate LR audio
  // ------------------------------------------------------
  audio_sample_t audio = separate_lr_audio(audio_mono, audio_lrdiff);

  // ------------------------------------------------------
  // Debug
  // ------------------------------------------------------

#ifndef __SYNTHESIS__
  static DataWriter writer_data_out_audio_mono("data_out_audio_mono.txt");
  writer_data_out_audio_mono.write(audio_mono);

  static DataWriter writer_data_out_audio_lrdiff("data_out_audio_lrdiff.txt");
  writer_data_out_audio_lrdiff.write(audio_lrdiff);

  static DataWriter writer_data_out_audio_L("data_out_audio_L.txt");
  writer_data_out_audio_L.write(audio.L);

  static DataWriter writer_data_out_audio_R("data_out_audio_R.txt");
  writer_data_out_audio_R.write(audio.R);
#endif

  // ------------------------------------------------------
  // Output
  // ------------------------------------------------------

  return audio;
}
