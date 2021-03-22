/*****************************************************************************/
/**
 * @file    main.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Implementation of testbench.
 */
/*****************************************************************************/

#include <iomanip>
#include <iostream>

#include "fm_receiver.hpp"
#include "helper/DataLoader.hpp"

using namespace std;

/* Constants */
constexpr double n_sec_c = 0.005;
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

    // Create output file
    ofstream fd_data_out;
    string folder_output = "./output/";
    fd_data_out.open(folder_output + "data_out_rx_pilot.txt", ios::out);
    if (!fd_data_out.is_open()) {
      cerr << "Failed to open 'output' file!" << endl;
      return -1;
    }

    // --------------------------------------------------------------------------
    // Run test on DUT
    // --------------------------------------------------------------------------
    cout << "--- Running test on DUT" << endl;

    // Apply stimuli, call the top-level function and save the results
    sample_t output;
    vector<sample_t> data_out_pilot;
    for (size_t i = 0; i < num_samples_c; i++) {
      output = fm_receiver(data_in_iq[i]);

      data_out_pilot.emplace_back(output);
      fd_data_out << std::fixed << std::setw(FP_WIDTH + 3)
                  << std::setprecision(FP_WIDTH_FRAC) << output.to_float()
                  << endl;
    }
    fd_data_out.close();

    // --------------------------------------------------------------------------
    // Compare results
    // --------------------------------------------------------------------------
    cout << "--- Comparing results" << endl;
    cout << "Comparing against max. absolute error: " << max_abs_err_c << endl;

    int failed_tests = 0;
    for (size_t i = 0; i < num_samples_c; i++) {
      // Check absolute error
      double err     = data_out_pilot[i] - data_gold_pilot[i];
      double abs_err = abs(err);

      if (abs_err > max_abs_err_c) {
        cerr << "Actual value [" << i << "] not matching the expected value!"
             << endl;
        cerr << "Errors: " << abs_err << " actual > max_err " << max_abs_err_c
             << endl;
        failed_tests += 1;
        break;
      }
    }

    if (failed_tests == 0) {
      cout << "===> Test passed <===\n" << endl;
    } else {
      cout << "===> Test failed <===\n" << endl;
      return -1;
    }
  } catch (const std::exception& e) {
    cerr << "Exception occured: " << e.what() << endl;
    return -1;
  }

  return 0;
}
