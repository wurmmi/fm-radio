/*****************************************************************************/
/**
 * @file    fm_global.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Header for global definitions.
 */
/*****************************************************************************/

#ifndef _FM_GLOBAL_HPP
#define _FM_GLOBAL_HPP

#include <ap_fixed.h>

#include "fm_global_spec.hpp"

typedef ap_fixed<FP_WIDTH, FP_WIDTH_INT> sample_t;
typedef sample_t coeff_t;
typedef sample_t acc_t;

const ap_fixed<4, 4> pilot_scale_factor_c = PILOT_SCALE_FACTOR;
const ap_fixed<5, 2> carrier_38k_offset_c = CARRIER_38K_OFFSET;

#endif /* _FM_GLOBAL_HPP */
