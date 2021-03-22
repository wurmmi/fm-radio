/*****************************************************************************/
/**
 * @file    main.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Implementation of testbench.
 */
/*****************************************************************************/

#include <iostream>

#include "fm_receiver.hpp"
#include "helper/DataLoader.hpp"
#include "helper/DataWriter.hpp"

using namespace std;

/* Constants */
constexpr double n_sec_c = 0.0003;
const int fs_c           = 960000;  // TODO: get this from file
const int fs_rx_c        = 120000;  // TODO: get this from file

constexpr int num_samples_fs_c = n_sec_c * fs_c;
constexpr int num_samples_c    = n_sec_c * fs_rx_c;
constexpr double max_abs_err_c = pow(2.0, -5);

const string folder_gold =
    "../../../../../../../../sim/matlab/verification_data/";

/* Testbench main function */
int main() {
  cout << "===============================================" << endl;
  cout << "### Running testbench ..." << endl;
  cout << "===============================================" << endl;

  try {
    // --------------------------------------------------------------------------
    // Load data from files
    // --------------------------------------------------------------------------
    cout << "--- Loading data from files" << endl;

    cout << "num_samples_fs = " << num_samples_fs_c << endl;
    cout << "num_samples    = " << num_samples_c << endl;

    // Golden output data
    string filename = folder_gold + "rx_pilot.txt";
    vector<sample_t> data_gold_pilot =
        DataLoader::loadDataFromFile(filename, num_samples_c);

    // Input data
    filename = folder_gold + "rx_fmChannelData.txt";
    vector<sample_t> data_in_iq =
        DataLoader::loadDataFromFile(filename, num_samples_c);

    // --------------------------------------------------------------------------
    // Run test on DUT
    // --------------------------------------------------------------------------
    cout << "--- Running test on DUT" << endl;

    // Apply stimuli, call the top-level function and save the results
    DataWriter writer_data_out_L("data_out_rx_audio_L.txt");
    sample_t output;
    for (size_t i = 0; i < num_samples_c; i++) {
      output = fm_receiver(data_in_iq[i]);

      writer_data_out_L.write(output);
    }

    cout << "--- Done." << endl;
  } catch (const std::exception& e) {
    cerr << "Exception occured: " << e.what() << endl;
    return -1;
  }

  return 0;
}
