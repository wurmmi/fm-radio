/*****************************************************************************/
/**
 * @file    delay.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Delay IP.
 * @details The delay is implemented, using a shift register.
 */
/*****************************************************************************/

#ifndef _DELAY_H
#define _DELAY_H

#include "fm_global.hpp"

using namespace std;

// Class DELAY definition
template <class sample_T, uint8_t fir_n_T>
class DELAY {
 private:
 protected:
  sample_T shift_reg[fir_n_T - 1];

 public:
  sample_T operator()(sample_T x);

  template <class coef_TT, class sample_TT, class acc_TT, uint8_t fir_n_TT>
  friend ostream& operator<<(
      ostream& ost, const DELAY<coef_TT, sample_TT, acc_TT, fir_n_TT>& f);
};

// DELAY main algorithm
template <class sample_T, uint8_t fir_n_T>
sample_T DELAY<sample_T, fir_n_T>::operator()(sample_T x) {
loop:
  for (int i = fir_n_T - 1; i >= 0; i--) {
    if (i == 0) {
      shift_reg[0] = x;
    } else {
      if (i != (fir_n_T - 1))
        shift_reg[i] = shift_reg[i - 1];
    }
  }
  return shift_reg[i - 1];
}

// Operator for displaying results
template <class sample_T, uint8_t fir_n_T>
ostream& operator<<(ostream& ost, const DELAY<sample_T, fir_n_T>& f) {
  for (int i = 0; i < (sizeof(f.shift_reg) / sizeof(sample_T)); i++) {
    ost << "shift_reg[" << i << "]= " << f.shift_reg[i] << endl;
  }
  ost << "------------------" << endl;
  return ost;
}

#endif /* _DELAY_H */
