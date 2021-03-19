/*****************************************************************************/
/**
 * @file    main.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Implementation of testbench.
 */
/*****************************************************************************/

#include <fstream>
#include <iostream>

#include "fm_global.hpp"
#include "fm_receiver.hpp"

using namespace std;

int main() {
  cout << "===============================================" << endl;
  cout << "### Running testbench ..." << endl;
  cout << "===============================================" << endl;

  ofstream result;
  sample_t output;
  int retval = 0;

  // Open a file to save the results
  result.open("data/result.dat");

  // Apply stimuli, call the top-level function and save the results
  for (int i = 0; i <= 250; i++) {
    output = fm_receiver(i);

    result << setw(10) << i;
    result << setw(20) << output;
    result << endl;
  }
  result.close();

  // Compare the results file with the golden results
  retval = system("diff --brief -w data/result.dat data/result.golden.dat");
  if (retval != 0) {
    printf("Test failed  !!!\n");
    retval = 1;
  } else {
    printf("Test passed !\n");
  }

  // Return 0 if the test passes
  return retval;
}
