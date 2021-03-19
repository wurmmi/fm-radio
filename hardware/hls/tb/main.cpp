/*****************************************************************************/
/**
 * @file    main.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Implementation for testbench.
 */
/*****************************************************************************/

#include <stdio.h>
#include <stdlib.h>

#include "fm_receiver.hpp"

using namespace std;

int main() {
  cout << "###############################################" << endl;
  cout << "### Running testbench ..." << endl;
  cout << "###############################################" << endl;

  hls::stream<axi_stream_element_t> signal_in_hw("signal_in_hw");
  hls::stream<axi_stream_element_t> signal_out_hw("signal_out_hw");
  hls::stream<axi_stream_element_t> signal_out_gold_hw("signal_out_gold_hw");

  sample_t signal_in[NUM_SAMPLES];
  sample_t signal_out_gold[NUM_SAMPLES];

  FILE *fp1 = nullptr;
  FILE *fp2 = nullptr;
  int err   = 0;

  // LOAD INPUT DATA  AND REFERENCE RESULTS
  cout << "--- Open files" << endl;
  fp1 = fopen("./data/input.dat", "r");
  if (fp1 == nullptr) {
    cout << "Could not open input file!" << endl;
    return -1;
  }
  fp2 = fopen("./data/output_gold.dat", "r");
  if (fp1 == nullptr) {
    cout << "Could not open output file!" << endl;
    return -1;
  }

  cout << "--- Read files" << endl;
  float val1;
  float val2;
  for (int i = 0; i < NUM_SAMPLES; i++) {
    fscanf(fp1, "%f\n", &val1);
    signal_in[i] = (sample_t)val1;
    fscanf(fp2, "%f\n", &val2);
    signal_out_gold[i] = (sample_t)val2;
  }
  fclose(fp1);
  fclose(fp2);

  cout << "### First run #################################" << endl;
  cout << "--- Convert data to streams" << endl;
  getArray2Stream_axi<NUM_SAMPLES, FP_WIDTH, axi_stream_element_t, sample_t>(
      signal_in, signal_in_hw);
  getArray2Stream_axi<NUM_SAMPLES, FP_WIDTH, axi_stream_element_t, sample_t>(
      signal_out_gold, signal_out_gold_hw);

  cout << "--- Send data to DUT" << endl;
  fm_receiver(signal_in_hw, signal_out_hw);

  cout << "--- Check results" << endl;
  err += checkStreamEqual_axi<axi_stream_element_t, sample_t>(
      signal_out_hw, signal_out_gold_hw, false);
  if (err)
    cout << "==> FAILED <==" << endl;
  cout << "==> PASSED <==" << endl;

  cout << "### Second run ################################" << endl;
  cout << "--- Convert data to streams" << endl;
  getArray2Stream_axi<NUM_SAMPLES, FP_WIDTH, axi_stream_element_t, sample_t>(
      signal_in, signal_in_hw);
  getArray2Stream_axi<NUM_SAMPLES, FP_WIDTH, axi_stream_element_t, sample_t>(
      signal_out_gold, signal_out_gold_hw);

  cout << "--- Send data to DUT" << endl;
  fm_receiver(signal_in_hw, signal_out_hw);

  cout << "--- Check results" << endl;
  err += checkStreamEqual_axi<axi_stream_element_t, sample_t>(
      signal_out_hw, signal_out_gold_hw, false);
  if (err)
    cout << "==> FAILED <==" << endl;
  cout << "==> PASSED <==" << endl;

  return err;
}
