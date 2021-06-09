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

const string data_folder =
    "../../../../../../../../sim/matlab/verification_data/";

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

    // Input data
    const string filename = data_folder + "rx_fm_bb.txt";
    vector<sample_t> data_in_iq =
        DataLoader::loadDataFromFile(filename, num_samples_fs_c * 2);

    // Split interleaved I/Q samples (take every other)
    hls::stream<iq_sample_t> stream_data_in;
    iq_sample_t sample_in;
    for (size_t i = 0; i < data_in_iq.size(); i += 2) {
      sample_in.i = data_in_iq[i];
      sample_in.q = data_in_iq[i + 1];
      stream_data_in << sample_in;
    }

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
    char git_hash_o[8]    = {0};
    char build_time_o[13] = {0};
    while (!stream_data_in.empty()) {
      fm_receiver_hls(stream_data_in,
                      stream_data_out,
                      led_ctrl,
                      git_hash_o,
                      build_time_o,
                      led_out_o);

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
    cout << "git_hash  : " << git_hash_o << endl;
    cout << "build_time: " << build_time_o << endl;

    cout << "- Store output stream to file" << endl;
    while (!stream_data_out.empty()) {
      audio_sample_t audio_sample = stream_data_out.read();
      writer_data_out_rx_audio_L.write(audio_sample.L);
      writer_data_out_rx_audio_R.write(audio_sample.R);
    }

    auto ts_stop  = chrono::high_resolution_clock::now();
    auto duration = chrono::duration_cast<chrono::seconds>(ts_stop - ts_start);

    cout << "--- Done." << endl;
    cout << "--- Took " << duration.count() << " seconds." << endl;
  } catch (const exception &e) {
    cerr << "Exception occured: " << e.what() << endl;
    return -1;
  }

  return 0;
}
