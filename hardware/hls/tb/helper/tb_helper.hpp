/*****************************************************************************/
/**
 * @file    tb_helper.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Header for testbench helper fucntions.
 */
/*****************************************************************************/

#ifndef _TB_HELPER_HPP
#define _TB_HELPER_HPP

#include <ap_axi_sdata.h>
#include <ap_fixed.h>
#include <hls_stream.h>

#include "fm_global.hpp"

template <int SIZE, int DATA_WIDTH, typename AXI_T, typename T>
void getArray2Stream_axi(T in[SIZE], hls::stream<AXI_T>& out) {
  AXI_T axi;
  int cnt = 0;

  for (int k = 0; k < SIZE; k++) {
    axi.data.range(FP_WIDTH - 1, 0)   = 0;
    axi.data.range(DATA_WIDTH - 1, 0) = in[k].range();
    axi.user                          = (cnt == 0) ? 1 : 0;
    axi.last                          = (cnt == SIZE) ? 1 : 0;
    axi.keep                          = -1;
    axi.id                            = 0;
    axi.dest                          = 0;
    out << axi;
    cnt++;
  }
}

template <typename AXI_T, typename T>
int checkStreamEqual_axi(hls::stream<AXI_T>& test,
                         hls::stream<AXI_T>& valid,
                         bool print_out = false) {
  int err = 0;
  while (!valid.empty()) {
    if (test.empty()) {
      printf("ERROR: empty early\n");
      return 1;
    }
    AXI_T axi_tmp       = test.read();
    AXI_T axi_tmp_valid = valid.read();

    T tmp;
    T tmp_valid;
    tmp.range()       = axi_tmp.data(FP_WIDTH - 1, 0);
    tmp_valid.range() = axi_tmp_valid.data(FP_WIDTH - 1, 0);

    if (print_out)
      printf("%f,%f\n", tmp.to_float(), tmp_valid.to_float());
    if ((tmp.to_float() > tmp_valid.to_float() + TB_ERROR_TOLERANCE) ||
        (tmp.to_float() < tmp_valid.to_float() - TB_ERROR_TOLERANCE)) {
      printf("ERROR: wrong value\n");
      err++;
      return err;
    }
  }
  if (!test.empty()) {
    printf("ERROR: still data in stream\n");
    err++;
    return err;
  }
  return err;
}

#endif /* _TB_HELPER_HPP */
