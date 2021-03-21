/*****************************************************************************/
/**
 * @file    main.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Implementation of testbench.
 */
/*****************************************************************************/

#include <fstream>
#include <iostream>
#include <vector>

#include "fm_global.hpp"
#include "fm_receiver.hpp"

using namespace std;

/* Constant s*/
constexpr double n_sec_c       = 0.005;
constexpr int fs_c             = 960000;  // TODO: check this
constexpr int fs_rx_c          = 120000;  // TODO: check this
constexpr int num_samples_fs_c = n_sec_c * fs_c;
constexpr int num_samples_c    = n_sec_c * fs_rx_c;

constexpr double max_abs_err_c = 2;  // TODO

/* Testbench main function */
int main() {
  cout << "===============================================" << endl;
  cout << "### Running testbench ..." << endl;
  cout << "===============================================" << endl;

  // --------------------------------------------------------------------------
  // Load data from files
  // --------------------------------------------------------------------------

  ifstream fd_data_in;
  ifstream fd_gold_pilot;
  ofstream fd_data_out;
  vector<sample_t> data_in;
  vector<sample_t> data_gold_pilot;
  vector<sample_t> data_out_pilot;

  cout << "num_samples_fs = " << num_samples_fs_c << endl;
  cout << "num_samples    = " << num_samples_c << endl;

  // Golden output data
  string folder_gold = "../../../../../../../../sim/matlab/verification_data/";
  fd_gold_pilot.open(folder_gold + "rx_pilot.txt", ios::in);
  if (!fd_gold_pilot.is_open()) {
    cerr << "Failed to open 'gold_pilot' file!" << endl;
    return -1;
  }
  double value = 0;
  while (fd_gold_pilot >> value) {
    data_gold_pilot.emplace_back(value);

    // Stop, if enough samples were read
    if (data_gold_pilot.size() >= num_samples_c)
      break;
  }
  fd_gold_pilot.close();

  // Check if enough samples were read
  size_t num_read = data_gold_pilot.size();
  if (num_read < num_samples_c) {
    cerr << "File 'data_gold_pilot' contains less elements than requested!"
         << endl;
    cerr << num_read << " < " << num_samples_c << endl;
    return -1;
  }

  // Input data
  fd_data_in.open(folder_gold + "rx_fmChannelData.txt", ios::in);
  if (!fd_data_in.is_open()) {
    cerr << "Failed to open 'input' file!" << endl;
    return -1;
  }
  value = 0;
  while (fd_data_in >> value) {
    data_in.emplace_back(value);

    if (data_in.size() >= num_samples_c)
      break;
  }
  fd_data_in.close();

  // Check if enough samples were read
  num_read = data_in.size();
  if (num_read < num_samples_c) {
    cerr << "File 'data_in' contains less elements than requested!" << endl;
    cerr << num_read << " < " << num_samples_c << endl;
    return -1;
  }

  // Create output file
  string folder_output = "./output/";
  fd_data_out.open(folder_output + "data_out_rx_pilot.txt", ios::out);
  if (!fd_data_out.is_open()) {
    cerr << "Failed to open 'output' file!" << endl;
    return -1;
  }

  // --------------------------------------------------------------------------
  // Run test on DUT
  // --------------------------------------------------------------------------

  // Apply stimuli, call the top-level function and save the results
  sample_t output;
  for (size_t i = 0; i < num_samples_c; i++) {
    output = fm_receiver(data_in[i]);

    data_out_pilot.emplace_back(output);
    fd_data_out << output << endl;
  }
  fd_data_out.close();

  // --------------------------------------------------------------------------
  // Compare results
  // --------------------------------------------------------------------------

  // Compare the simulation results with the golden results
  int retval = 0;
  for (size_t i = 0; i < num_samples_c; i++) {
    // Check absolute error
    double err = data_out_pilot[i] - data_gold_pilot[i];
    cout << "err: " << err << endl;
    if (abs(err) > max_abs_err_c) {
      cerr << "Actual value [i] not matching the expected value!" << endl;
      cerr << "Errors: act > max_err" << endl;
      retval = -1;
      break;
    }
  }

  if (retval != 0) {
    cout << "===> Test failed  !!!" << endl;
    retval = 1;
  } else {
    cout << "===> Test passed !" << endl;
  }

  // Return 0 if the test passes
  return retval;
}
