/*****************************************************************************/
/**
 * @file    main.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Implementation of testbench.
 */
/*****************************************************************************/

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

    /*--- Load data like firmware (from Matlab *.wav file) ---*/

    // Load file data
    WavReader wavReader;
    const string filename_wav =
        data_dir_fw_resource + "wav/cantina_band_44100.wav";
    wavReader.LoadFile(filename_wav);
    auto buffer = wavReader.GetBuffer();

    // Transform into I/Q samples
    uint32_t* pSource = (uint32_t*)buffer.buffer;
    vector<iq_sample_t> vec_data_wav_in;
    hls::stream<iq_sample_t> stream_data_wav_in;
    iq_sample_t sample_wav_in;
    for (uint32_t i = 0; i < buffer.size / 4; i++) {
      // Split 32 bit into 2x 16 bit

      // ############################################
      // ############################################
      // ############################################
      // ############################################
      // ############################################
      // ############################################
      // ############################################
      // ############################################
      // ############################################
      //
      // ERROR IS HERE IN CONVERSION!!!
      //
      // ############################################
      // ############################################
      // ############################################
      // ############################################
      // ############################################
      // ############################################
      sample_wav_in.i = (sample_t)((pSource[i] >> 16) & 0xFFFF);
      sample_wav_in.q = (sample_t)((pSource[i] >> 0) & 0xFFFF);

      // Fill stream
      stream_data_wav_in << sample_wav_in;
      vec_data_wav_in.emplace_back(sample_wav_in);
    }

    /*--- Load data directly (from Matlab *.txt file) ---*/

    // Load file data
    const string filename_txt = data_dir_verification + "rx_fm_bb.txt";
    vector<sample_t> data_in_iq =
        DataLoader::loadDataFromFile(filename_txt, num_samples_fs_c * 2);

    // Split interleaved I/Q samples
    vector<iq_sample_t> vec_data_in;
    hls::stream<iq_sample_t> stream_data_in;
    iq_sample_t sample_in;
    for (size_t i = 0; i < data_in_iq.size(); i += 2) {
      // Samples I/Q are interleaved (take every other)
      sample_in.i = data_in_iq[i];
      sample_in.q = data_in_iq[i + 1];

      // Fill stream
      stream_data_in << sample_in;
      vec_data_in.emplace_back(sample_in);
    }

    /*--- Compare the 2 data loading methods ---*/

    cout << "--- Checking data loading results" << endl;

    cout << "- Check amount of data" << endl;
    if (vec_data_wav_in.size() != vec_data_in.size()) {
      cerr << "ERROR: amount of loaded data does not match!" << endl;
      cerr << "vec_data_in : " << vec_data_in.size() << endl;
      cerr << "vec_data_wav_in : " << vec_data_wav_in.size() << endl;
    } else {
      cout << "OKAY" << endl;
    }

    cout << "- Write to files for visual compare" << endl;
    DataWriter writer_vec_data_in("vec_data_in.txt");
    DataWriter writer_vec_data_wav_in("vec_data_wav_in.txt");
    writer_vec_data_in.write(vec_data_in);
    writer_vec_data_wav_in.write(vec_data_wav_in);

    // --------------------------------------------------------------------------
    // Run test on DUT
    // --------------------------------------------------------------------------
    cout << "--- Running test on DUT" << endl;

    // Apply stimuli, call the top-level function and save the results
    DataWriter writer_data_out_rx_audio_L("data_out_rx_audio_L.txt");
    DataWriter writer_data_out_rx_audio_R("data_out_rx_audio_R.txt");

    hls::stream<audio_sample_t> stream_data_out;
    uint8_t led_ctrl = 0x3;
    uint8_t led_out_o;
    status_git_hash_t status_git_hash_o;
    status_build_time_t status_build_time_o;
    while (!stream_data_in.empty()) {
      fm_receiver_hls(stream_data_in,
                      stream_data_out,
                      led_ctrl,
                      &status_git_hash_o,
                      &status_build_time_o,
                      &led_out_o);

      // std::bitset<8> led_out_o_bit(led_out_o);
      // cout << "led_out_o: " << hex << led_out_o_bit << endl;
    }

    cout << "--- Checking results" << endl;
    cout << "- Check LED output" << endl;
    if (led_ctrl != led_out_o)
      cerr << "ERROR: LED control not matching LED output" << endl;
    else
      cout << "OKAY" << endl;

    cout << "- Check build info status register" << endl;
    cout << "status_git_hash   : " << hex << status_git_hash_o << endl;
    cout << "status_build_time : " << hex << status_build_time_o << endl;

    cout << "- Store output stream to file" << endl;
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
