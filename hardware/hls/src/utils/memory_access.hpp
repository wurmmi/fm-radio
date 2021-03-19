/*****************************************************************************/
/**
 * @file    memory_access.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Header for memory access functions.
 */
/*****************************************************************************/

#ifndef _MEMORY_ACCESS_HPP
#define _MEMORY_ACCESS_HPP

#include <ap_axi_sdata.h>
#include <ap_fixed.h>
#include <hls_stream.h>

#include "fm_global.hpp"

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

    type_t val                      = out.read();
    tmp.data.range(FP_WIDTH - 1, 0) = 0;
    tmp.data.range(FP_WIDTH - 1, 0) = val.range();
    tmp.keep                        = -1;
    out_hw.write(tmp);
  }
}

#endif /* _MEMORY_ACCESS_HPP */
