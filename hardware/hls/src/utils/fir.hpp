/*****************************************************************************/
/**
 * @file    fir.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FIR IP header.
 * @details Partially taken from Vivado HLS design examples, by Xilinx Inc.
 *          Can be found in the Vivado install directory under
 *          e.g. Xilinx/Vivado/2018.2/examples/coding/cpp_FIR
 */
/*****************************************************************************/

#ifndef _FIR_H
#define _FIR_H

#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>

#include "fm_global.hpp"

using namespace std;

// Class FIR definition
template <class coeff_T, class sample_T, class acc_T, uint8_t fir_n_T>
class FIR {
 private:
 protected:
  sample_T shift_reg[fir_n_T - 1];

 public:
  sample_T operator()(sample_T x, const coeff_T coeff[fir_n_T]);

  template <class coef_TT, class sample_TT, class acc_TT, uint8_t fir_n_TT>
  friend ostream& operator<<(
      ostream& ost, const FIR<coef_TT, sample_TT, acc_TT, fir_n_TT>& f);
};

// FIR main algorithm
template <class coeff_T, class sample_T, class acc_T, uint8_t fir_n_T>
sample_T FIR<coeff_T, sample_T, acc_T, fir_n_T>::operator()(
    sample_T x, const coeff_T coeff[fir_n_T]) {
  acc_T acc = 0;
  sample_T m;

loop:
  for (int i = fir_n_T - 1; i >= 0; i--) {
    if (i == 0) {
      m            = x;
      shift_reg[0] = x;
    } else {
      m = shift_reg[i - 1];
      if (i != (fir_n_T - 1))
        shift_reg[i] = shift_reg[i - 1];
    }
    acc += m * coeff[i];
  }
  return acc;
}

// Operator for displaying results
template <class coeff_T, class sample_T, class acc_T, uint8_t fir_n_T>
ostream& operator<<(ostream& ost,
                    const FIR<coeff_T, sample_T, acc_T, fir_n_T>& f) {
  for (int i = 0; i < (sizeof(f.shift_reg) / sizeof(sample_T)); i++) {
    ost << "shift_reg[" << i << "]= " << f.shift_reg[i] << endl;
  }
  ost << "------------------" << endl;
  return ost;
}

///* Top-level function.
// * Instantiates the FIR class with correct template parameters.
// */
// template <class coeff_T, class sample_T, class acc_T, uint8_t fir_n_T>
// sample_T fir_filter_top(sample_T x, const coeff_T coeff[fir_n_T]) {
//  static FIR<coeff_T, sample_T, acc_T, fir_n_T> fir_inst;
//
//  // cout << fir_inst;
//
//  return fir_inst(x, coeff);
//}

#endif /* _FIR_H */
