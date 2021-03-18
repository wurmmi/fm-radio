/*****************************************************************************/
/**
 * @file    fm_global.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Header for global definitions.
 */
/*****************************************************************************/

#ifndef _FM_GLOBAL_HPP
#define _FM_GLOBAL_HPP

#include <ap_axi_sdata.h>
#include <ap_fixed.h>
#include <hls_stream.h>

#define NUM_SAMPLES     1024
#define ERROR_TOLERANCE 0.1

#define FP_WIDTH      ((uint32_t)16)
#define FP_WIDTH_FRAC ((uint32_t)14)
#define FP_WIDTH_INT  (FP_WIDTH - FP_WIDTH_FRAC)

typedef ap_axis<FP_WIDTH, 1, 1, 1> axi_stream_element_t;
typedef hls::stream<axi_stream_element_t> axi_stream_t;

typedef ap_fixed<2 * FP_WIDTH, 2> iq_sample_t;
typedef ap_fixed<FP_WIDTH, 2> sample_t;

template <typename axi_t, typename type_t, int SIZE>
void mem_read(hls::stream<axi_t>& in_hw, hls::stream<type_t>& in) {
#pragma HLS INTERFACE axis port = in_hw
#pragma HLS INTERFACE axis port = in
#pragma HLS STREAM variable     = in_hw
#pragma HLS STREAM variable     = in

  axi_t axi;

loop_size:
  for (int i = 0; i < SIZE; i++) {
#pragma HLS LOOP_FLATTEN off
#pragma HLS PIPELINE II = 1

    axi = in_hw.read();
    type_t tmp;
    tmp.range() = axi.data(FP_WIDTH - 1, 0);
    in.write(tmp);
  }
}

template <typename axi_t, typename type_t, int SIZE>
void mem_write(hls::stream<type_t>& out, hls::stream<axi_t>& out_hw) {
#pragma HLS INTERFACE axis port = out_hw
#pragma HLS INTERFACE axis port = out
#pragma HLS STREAM variable     = out_hw
#pragma HLS STREAM variable     = out

  int eol = 0;
  int sof = 1;
  axi_t tmp;

write_loop:
  for (int i = 0; i < SIZE; i++) {
#pragma HLS PIPELINE II = 1
#pragma HLS LOOP_FLATTEN off
    // set flags
    if (sof) {
      tmp.user = 1;
      sof      = 0;
    } else {
      tmp.user = 0;
    }
    if (i == SIZE - 1) {
      tmp.last = 1;
    } else {
      tmp.last = 0;
    }

    type_t val                       = out.read();
    tmp.data.range(64 - 1, FP_WIDTH) = 0;
    tmp.data.range(FP_WIDTH - 1, 0)  = val.range();
    tmp.keep                         = -1;
    out_hw.write(tmp);
  }
}

template <int SIZE, int DATA_WIDTH, typename AXI_T, typename T>
void getArray2Stream_axi(T in[SIZE], hls::stream<AXI_T>& out) {
  AXI_T axi;
  int cnt = 0;

  for (int k = 0; k < SIZE; k++) {
    axi.data.range(64 - 1, DATA_WIDTH) = 0;
    axi.data.range(DATA_WIDTH - 1, 0)  = in[k].range();
    axi.user                           = (cnt == 0) ? 1 : 0;
    axi.last                           = (cnt == SIZE) ? 1 : 0;
    axi.keep                           = -1;
    axi.id                             = 0;
    axi.dest                           = 0;
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
    if ((tmp.to_float() > tmp_valid.to_float() + ERROR_TOLERANCE) ||
        (tmp.to_float() < tmp_valid.to_float() - ERROR_TOLERANCE)) {
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

#endif /* _FM_GLOBAL_HPP */
