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

void channel_decoder(hls::stream<sample_t>& sample_in,
                     sample_t& out_audio_L,
                     sample_t& out_audio_R) {
  sample_t carrier_38k;
  sample_t carrier_57k;
  sample_t audio_mono;
  sample_t audio_lrdiff;

  for (uint32_t i = 0; i < OSR_AUDIO; i++) {
    sample_t in_sample = sample_in.read();

    // ------------------------------------------------------
    // Recover carriers
    // ------------------------------------------------------
    recover_carriers(in_sample, carrier_38k, carrier_57k);

    // ------------------------------------------------------
    // Recover mono audio
    // ------------------------------------------------------
    audio_mono = recover_mono(in_sample);

    // ------------------------------------------------------
    // Recover LR diff audio
    // ------------------------------------------------------
    audio_lrdiff = recover_lrdiff(in_sample, carrier_38k);

    // ------------------------------------------------------
    // Debug
    // ------------------------------------------------------
#ifndef __SYNTHESIS__
    static DataWriter writer_data_out_fm_channel_data(
        "data_out_fm_channel_data.txt");
    writer_data_out_fm_channel_data.write(in_sample);

    static DataWriter writer_data_out_carrier_38k("data_out_carrier_38k.txt");
    writer_data_out_carrier_38k.write(carrier_38k);
#endif
  }

  // ------------------------------------------------------
  // Decimate
  // ------------------------------------------------------

  // mono audio
  sample_t audio_mono_dec   = audio_mono;
  bool audio_mono_dec_valid = true;

  // LR diff audio
  sample_t audio_lrdiff_dec   = audio_lrdiff;
  bool audio_lrdiff_dec_valid = true;

  // ------------------------------------------------------
  // Separate LR audio
  // ------------------------------------------------------
  if (audio_mono_dec_valid && audio_lrdiff_dec_valid) {
    sample_t audio_L;
    sample_t audio_R;
    separate_lr_audio(audio_mono_dec, audio_lrdiff_dec, audio_L, audio_R);

    // ------------------------------------------------------
    // Output
    // ------------------------------------------------------

    out_audio_L = audio_L;
    out_audio_R = audio_R;

    // ------------------------------------------------------
    // Debug
    // ------------------------------------------------------

#ifndef __SYNTHESIS__
    static DataWriter writer_data_out_audio_mono("data_out_audio_mono.txt");
    writer_data_out_audio_mono.write(audio_mono);

    static DataWriter writer_data_out_audio_lrdiff("data_out_audio_lrdiff.txt");
    writer_data_out_audio_lrdiff.write(audio_lrdiff);

    static DataWriter writer_data_out_audio_L("data_out_audio_L.txt");
    writer_data_out_audio_L.write(audio_L);

    static DataWriter writer_data_out_audio_R("data_out_audio_R.txt");
    writer_data_out_audio_R.write(audio_R);
#endif
  }
}
