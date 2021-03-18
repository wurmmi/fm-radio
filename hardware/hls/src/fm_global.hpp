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

typedef ap_axis<32, 1, 1, 1> axi_stream_element_t;
typedef hls::stream<axi_stream_element_t> axi_stream_t;

typedef ap_fixed<32, 2> iq_sample_t;
typedef ap_fixed<16, 2> sample_t;

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
    tmp.range() = axi.data(DATA_WIDTH_IN - 1, 0);
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

    type_t val                             = out.read();
    tmp.data.range(64 - 1, DATA_WIDTH_OUT) = 0;
    tmp.data.range(DATA_WIDTH_OUT - 1, 0)  = val.range();
    tmp.keep                               = -1;
    out_hw.write(tmp);
  }
}

#endif /* _FM_GLOBAL_HPP */
