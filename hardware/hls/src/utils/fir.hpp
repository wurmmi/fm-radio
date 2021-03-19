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

#define FIR_N 85

typedef int coef_t;
typedef int acc_t;

// Class CFir definition
template <class coef_T, class sample_t, class acc_T>
class CFir {
 protected:
  static const coef_T c[FIR_N];
  sample_t shift_reg[FIR_N - 1];

 private:
 public:
  sample_t operator()(sample_t x);
  template <class coef_TT, class sample_tT, class acc_TT>
  friend ostream& operator<<(ostream& o,
                             const CFir<coef_TT, sample_tT, acc_TT>& f);
};

// Load FIR coefficients
template <class coef_T, class sample_t, class acc_T>
const coef_T CFir<coef_T, sample_t, acc_T>::c[FIR_N] = {
#include "fir_coeffs.inc"
};

// FIR main algorithm
template <class coef_T, class sample_t, class acc_T>
sample_t CFir<coef_T, sample_t, acc_T>::operator()(sample_t x) {
  int i;
  acc_t acc = 0;
  sample_t m;

loop:
  for (i = FIR_N - 1; i >= 0; i--) {
    if (i == 0) {
      m            = x;
      shift_reg[0] = x;
    } else {
      m = shift_reg[i - 1];
      if (i != (FIR_N - 1))
        shift_reg[i] = shift_reg[i - 1];
    }
    acc += m * c[i];
  }
  return acc;
}

// Operator for displaying results
template <class coef_T, class sample_t, class acc_T>
ostream& operator<<(ostream& o, const CFir<coef_T, sample_t, acc_T>& f) {
  for (int i = 0; i < (sizeof(f.shift_reg) / sizeof(sample_t)); i++) {
    o << "shift_reg[" << i << "]= " << f.shift_reg[i] << endl;
  }
  o << "______________" << endl;
  return o;
}

sample_t fir_filter(sample_t x);

#endif /* _FIR_H */
