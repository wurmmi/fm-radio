/*****************************************************************************/
/**
 * @file    main.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Implementation of testbench.
 */
/*****************************************************************************/

/* ------------------------------ */
/* NOTE:
 * This is a workaround for an issue with the gmp-library.
 * https://forums.xilinx.com/t5/High-Level-Synthesis-HLS/Vivado-2015-3-HLS-Bug-gmp-h/td-p/661141
 */
#include <gmp.h>
#define __gmp_const const
/* ------------------------------ */
#include <hls_math.h>

#include <bitset>
#include <chrono>
#include <iostream>

#include "FileReader/WavReader.h"
#include "fm_receiver_hls.hpp"
#include "helper/DataLoader.hpp"
#include "helper/DataWriter.hpp"

using namespace std;

/* Constants */
#ifdef __RTL_SIMULATION__
constexpr double n_sec_c = 0.001;
#else
constexpr double n_sec_c = 0.1;
#endif

#define DEBUG_OUTPUT 0

const string repo_root = "../../../../../../../../";
const string data_dir_verification =
    repo_root + "sim/matlab/verification_data/";
const string data_dir_fw_resource =
    repo_root + "hardware/vivado/sdk/fm_radio_app/resource/";

/* Derived constants */
constexpr int num_samples_fs_c    = n_sec_c * FS;
constexpr int num_samples_rx_c    = n_sec_c * FS_RX;
constexpr int num_samples_audio_c = n_sec_c * FS_AUDIO;

/* Testbench main function */
int main() {
  cout << "===============================================" << endl;
  cout << "### Running testbench ..." << endl;
  cout << "===============================================" << endl;

  auto ts_start = chrono::high_resolution_clock::now();

  try {
    // --------------------------------------------------------------------------
    // Load data from files
    // --------------------------------------------------------------------------
    cout << "--- Loading data from files" << endl;

    cout << "num_samples_fs    = " << num_samples_fs_c << endl;
    cout << "num_samples_rx    = " << num_samples_rx_c << endl;
    cout << "num_samples_audio = " << num_samples_audio_c << endl;

    /*--- Load data directly (from Matlab *.txt file) ---*/
    cout << "- Loading data from *.TXT" << endl;

    // Load file data
    const string filename_txt = data_dir_verification + "rx_fm_bb.txt";
    vector<sample_t> data_in_iq =
        DataLoader::loadDataFromFile(filename_txt, num_samples_fs_c * 2);

    // Split interleaved I/Q samples
    vector<iq_sample_t> vec_data_txt_in;
    for (size_t i = 0; i < data_in_iq.size(); i += 2) {
      // Samples I/Q are interleaved (take every other)
      iq_sample_t sample_in;
      sample_in.i = data_in_iq[i];
      sample_in.q = data_in_iq[i + 1];

      // Store in vector
      vec_data_txt_in.emplace_back(sample_in);
    }

    /*--- Load data like firmware (from Matlab *.wav file) ---*/
    cout << "- Loading data from *.WAV" << endl;

    // Load file data
    WavReader wavReader;
    const string filename_wav = data_dir_fw_resource + "wav/rx_fm_bb.wav";
    wavReader.LoadFile(filename_wav);
    auto buffer = wavReader.GetBuffer();

    // Transform into I/Q samples
    uint32_t* pSource = (uint32_t*)buffer.buffer;
    vector<iq_sample_t> vec_data_wav_in;
    iq_sample_t sample_wav_in;
    for (uint32_t i = 0; i < buffer.size / 4; i++) {
      // Split 32 bit into 2x 16 bit
      int16_t left  = (int16_t)((pSource[i] >> 16) & 0xFFFF);
      int16_t right = (int16_t)((pSource[i] >> 0) & 0xFFFF);

      // Convert to ap_fixed data type
      sample_wav_in.i.range() = left;
      sample_wav_in.q.range() = right;

      // Store in vector
      vec_data_wav_in.emplace_back(sample_wav_in);
    }

    /*--- Compare the 2 data loading methods ---*/

    cout << "--- Checking data loading results" << endl;

    cout << "- Check amount of data" << endl;
    if (vec_data_wav_in.size() < vec_data_txt_in.size()) {
      cerr << "ERROR: WAV file contains too few data values!" << endl;
      cerr << "vec_data_txt_in : " << vec_data_txt_in.size() << endl;
      cerr << "vec_data_wav_in : " << vec_data_wav_in.size() << endl;
    }

    cout << "- Compare data values" << endl;
    uint32_t value_error_count = 0;
    for (uint32_t i = 0; i < vec_data_txt_in.size(); i++) {
      iq_sample_t txt_in = vec_data_txt_in[i];
      iq_sample_t wav_in = vec_data_wav_in[i];
      if (!(txt_in == wav_in)) {
        /** NOTE:
         * Some values differ by a small amount, for some reason.
         * There may be a bit-error in the type-casts somewhere in the
         * read/write chain from Matlab to here.. will need to investigate
         * this at some point.
         */
        const sample_t max_abs_error = pow(2, -14);
        sample_t abs_err;
        abs_err    = hls::abs(txt_in.i - wav_in.i);
        bool err_i = (abs_err > max_abs_error);
        abs_err    = hls::abs(txt_in.q - wav_in.q);
        bool err_q = (abs_err > max_abs_error);

        bool err = err_i || err_q;
        if (err) {
          cerr << "ERROR: values don't match! (idx=" << i << ")" << endl;
          cerr << "txt_in: " << txt_in << endl;
          cerr << "wav_in: " << wav_in << endl;
          value_error_count++;
          if (value_error_count > 10)
            break;
        }
      }
    }

#if defined DEBUG_OUTPUT && DEBUG_OUTPUT > 0
    cout << "- Write to files for visual compare" << endl;
    // shrink wav vector to the size of the txt vector
    vec_data_wav_in.resize(vec_data_txt_in.size());
    // write to file
    DataWriter writer_vec_data_in("vec_data_txt_in.txt");
    DataWriter writer_vec_data_wav_in("vec_data_wav_in.txt");
    writer_vec_data_in.write(vec_data_txt_in);
    writer_vec_data_wav_in.write(vec_data_wav_in);
#endif

    // --------------------------------------------------------------------------
    // Run test on DUT
    // --------------------------------------------------------------------------
    cout << "--- Running test on DUT" << endl;

    // Fill input stream (use WAV data; amount is determined by TXT-Matlab)
    hls::stream<iq_sample_t> stream_data_in;
    for (uint32_t i = 0; i < vec_data_txt_in.size(); i++) {
      stream_data_in << vec_data_wav_in[i];
    }

    // Apply stimuli to the top-level function
    hls::stream<audio_sample_t> stream_data_out;
    ap_int<NUM_LEDS> led_out_o;
    status_t status_o;
    config_t config = {.led_ctrl = 0x3, .enable_fm_radio_ip = 1};

    while (!stream_data_in.empty()) {
      fm_receiver_hls(
          stream_data_in, stream_data_out, config, &status_o, &led_out_o);

#if defined DEBUG_OUTPUT && DEBUG_OUTPUT > 0
      std::bitset<8> led_out_o_bit(led_out_o);
      cout << "led_out_o: " << hex << led_out_o_bit << endl;
#endif
    }

    cout << "--- Checking results" << endl;
    cout << "- Check LED output" << endl;
    if (config.led_ctrl != led_out_o)
      cerr << "ERROR: LED control not matching LED output" << endl;

    cout << "- Check build info status register" << endl;
    cout << "status.git_hash   : " << hex << status_o.git_hash << endl;
    cout << "status.build_time : " << hex << status_o.build_time << endl;

    cout << "- Store output stream to file" << endl;
    DataWriter writer_data_out_rx_audio_L("data_out_rx_audio_L.txt");
    DataWriter writer_data_out_rx_audio_R("data_out_rx_audio_R.txt");

    while (!stream_data_out.empty()) {
      audio_sample_t audio_sample = stream_data_out.read();
      writer_data_out_rx_audio_L.write(audio_sample.L);
      writer_data_out_rx_audio_R.write(audio_sample.R);
    }

    auto ts_stop  = chrono::high_resolution_clock::now();
    auto duration = chrono::duration_cast<chrono::seconds>(ts_stop - ts_start);

    cout << "--- Done." << endl;
    cout << "--- Took " << to_string(duration.count()) << " seconds." << endl;
  } catch (const exception& e) {
    cerr << "Exception occured: " << e.what() << endl;
    return -1;
  }

  return 0;
}
