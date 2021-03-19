/*****************************************************************************/
/**
 * @file    fm_receiver.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver IP implementation.
 */
/*****************************************************************************/

/*
-- TIME LOGGING
--
-- (1) FIR filter implementation
--       03/18/2021  17:00 - 19:00    2:00 h
--       03/19/2021  09:30 -          x:xx h
--
-- (2) FM receiver implementation
--
*/

#include "fm_receiver.hpp"

#include <stdio.h>

#include "utils/fir.hpp"

void fm_receiver(axi_stream_t &src, axi_stream_t &dst) {
#pragma HLS INTERFACE s_axilite port = return bundle = ctrl
#pragma HLS INTERFACE axis port                      = src
#pragma HLS INTERFACE axis port                      = dst
#pragma HLS STREAM variable                          = src
#pragma HLS STREAM variable                          = dst

  hls::stream<sample_t> in(" data_in");
  hls::stream<sample_t> out("data_out");

#pragma HLS STREAM variable = in depth = 1 + 1
#pragma HLS STREAM variable = out depth = 1 + 1

#pragma HLS DATAFLOW

  // Read from the input AXI-Stream interface
  mem_read<axi_stream_element_t, sample_t, NUM_SAMPLES>(src, in);
  // FIR filter
  fir_filter(in, out, fir_coeffs_c);
  // Write to the output AXI-Stream interface
  mem_write<axi_stream_element_t, sample_t, NUM_SAMPLES>(out, dst);
}
