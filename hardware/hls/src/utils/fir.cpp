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

/* Top-level function.
 * Instantiates the FIR class with correct template parameters.
 */
template <class coeff_T, class sample_T, class acc_T, uint8_t fir_n_T>
sample_T fir_filter(sample_T x) {
  static FIR<coeff_T, sample_T, acc_T, fir_n_T> fir_inst;

  // cout << fir_inst;

  return fir_inst(x, fir_n_T);
}
