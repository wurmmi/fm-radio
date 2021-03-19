/*****************************************************************************/
/**
 * @file    fir.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FIR IP implementation.
 * @details Partially taken from Vivado HLS design examples, by Xilinx Inc.
 *          Can be found in the Vivado install directory under
 *          e.g. Xilinx/Vivado/2018.2/examples/coding/cpp_FIR
 */
/*****************************************************************************/

#include "fir.hpp"

/* Top-level function with FIR class instantiated */
sample_t fir_filter(sample_t x) {
  static CFir<coef_t, sample_t, acc_t> fir_inst;

  // cout << fir_inst;

  return fir_inst(x);
}
