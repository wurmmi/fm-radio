/*****************************************************************************/
/**
 * @file    fm_global.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Header for global definitions.
 */
/*****************************************************************************/

#ifndef _FM_GLOBAL_HPP
#define _FM_GLOBAL_HPP

/* ------------------------------ */
/* NOTE:
 * This is a workaround for an issue with the gmp-library.
 * https://forums.xilinx.com/t5/High-Level-Synthesis-HLS/Vivado-2015-3-HLS-Bug-gmp-h/td-p/661141
 */
#include <gmp.h>
#define __gmp_const const
/* ------------------------------ */

#include <ap_fixed.h>

#include "fm_global_spec.hpp"

typedef ap_fixed<FP_WIDTH, FP_WIDTH_INT> sample_t;
typedef sample_t coeff_t;
typedef sample_t acc_t;

const ap_fixed<4, 4> pilot_scale_factor_c = PILOT_SCALE_FACTOR;
const ap_fixed<5, 2> carrier_38k_offset_c = CARRIER_38K_OFFSET;

#endif /* _FM_GLOBAL_HPP */
