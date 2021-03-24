/*****************************************************************************/
/**
 * @file    main.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Implementation of testbench.
 */
/*****************************************************************************/

#include <chrono>
#include <iostream>

#include "fm_receiver.hpp"
#include "helper/DataLoader.hpp"
#include "helper/DataWriter.hpp"

using namespace std;

/* Constants */
constexpr double n_sec_c = 0.1;     // TODO: get this from file
const int fs_c           = 960000;  // TODO: get this from file
const int fs_rx_c        = 120000;  // TODO: get this from file

constexpr int num_samples_fs_c = n_sec_c * fs_c;
constexpr int num_samples_c    = n_sec_c * fs_rx_c;

const string data_folder =
    "../../../../../../../../sim/matlab/verification_data/";

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

    cout << "num_samples_fs = " << num_samples_fs_c << endl;
    cout << "num_samples    = " << num_samples_c << endl;

    // Input data
    const string filename = data_folder + "rx_fm_bb.txt";
    vector<sample_t> data_in_iq =
        DataLoader::loadDataFromFile(filename, num_samples_fs_c * 2);

    // Split interleaved I/Q samples (take every other)
    vector<sample_t> data_in_i;
    vector<sample_t> data_in_q;
    for (size_t i = 0; i < data_in_iq.size(); i++) {
      if (i % 2 == 0)
        data_in_i.emplace_back(data_in_iq[i]);
      else
        data_in_q.emplace_back(data_in_iq[i]);
    }

    // --------------------------------------------------------------------------
    // Run test on DUT
    // --------------------------------------------------------------------------
    cout << "--- Running test on DUT" << endl;

    // Apply stimuli, call the top-level function and save the results
    DataWriter writer_data_out_L("data_out_rx_audio_L.txt");
    DataWriter writer_data_out_R("data_out_rx_audio_R.txt");
    sample_t audio_L;
    sample_t audio_R;
    for (size_t i = 0; i < num_samples_fs_c; i++) {
      fm_receiver(data_in_i[i], data_in_q[i], audio_L, audio_R);

      writer_data_out_L.write(audio_L);
      writer_data_out_R.write(audio_R);
    }

    auto ts_stop  = chrono::high_resolution_clock::now();
    auto duration = chrono::duration_cast<chrono::seconds>(ts_stop - ts_start);

    cout << "--- Done." << endl;
    cout << "--- Took " << duration.count() << " seconds." << endl;
  } catch (const exception& e) {
    cerr << "Exception occured: " << e.what() << endl;
    return -1;
  }

  return 0;
}
