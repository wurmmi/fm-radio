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
template <class sample_T, uint8_t delay_n_T>
class DELAY {
 private:
 protected:
  sample_T shift_reg[delay_n_T];

 public:
  sample_T operator()(sample_T x);

  template <class sample_TT, uint8_t delay_n_TT>
  friend ostream& operator<<(ostream& ost,
                             const DELAY<sample_TT, delay_n_TT>& f);
};

// DELAY main algorithm
template <class sample_T, uint8_t delay_n_T>
sample_T DELAY<sample_T, delay_n_T>::operator()(sample_T x) {
loop:
  for (int i = 0; i < delay_n_T + 1; i++) {
#pragma HLS unroll
    shift_reg[i] = shift_reg[i + 1];
  }
  shift_reg[delay_n_T] = x;

  return shift_reg[0];
}

// Operator for displaying results
template <class sample_T, uint8_t delay_n_T>
ostream& operator<<(ostream& ost, const DELAY<sample_T, delay_n_T>& f) {
  for (int i = 0; i < delay_n_T + 1; i++) {
    ost << "shift_reg[" << i << "]= " << f.shift_reg[i] << endl;
  }
  ost << "------------------" << endl;
  return ost;
}

#endif /* _DELAY_H */
