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
#include "fm_receiver.hpp"

using namespace std;

// TODO: remove this comment block
// PYTHON NAMES
//    data_out_fm_demod = []
//    data_out_decimator = []
//    data_out_audio_mono = []
//    data_out_pilot = []
//    data_out_carrier_38k = []
//    data_out_audio_lrdiff = []
//    data_out_audio_L = []
//    data_out_audio_R = []

void channel_decoder(sample_t const& in_sample,
                     sample_t& out_audio_L,
                     sample_t& out_audio_R) {
  // ------------------------------------------------------
  // Recover carriers
  // ------------------------------------------------------
  sample_t carrier_38k;
  sample_t carrier_57k;
  recover_carriers(in_sample, carrier_38k, carrier_57k);

  // ------------------------------------------------------
  // Debug
  // ------------------------------------------------------
  static DataWriter writer_data_out_carrier_38k("data_out_carrier_38k.txt");
  writer_data_out_carrier_38k.write(carrier_38k);
}
