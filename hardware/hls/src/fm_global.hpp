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

#define NUM_SAMPLES 1024

#define FP_WIDTH      ((uint32_t)16)
#define FP_WIDTH_FRAC ((uint32_t)14)
#define FP_WIDTH_INT  (FP_WIDTH - FP_WIDTH_FRAC)

typedef ap_axis<FP_WIDTH, 1, 1, 1> axi_stream_element_t;
typedef hls::stream<axi_stream_element_t> axi_stream_t;

typedef ap_fixed<2 * FP_WIDTH, FP_WIDTH_INT> iq_sample_t;
typedef ap_fixed<FP_WIDTH, FP_WIDTH_INT> sample_t;

#endif /* _FM_GLOBAL_HPP */
