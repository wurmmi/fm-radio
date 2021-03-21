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

#define NUM_SAMPLES 1024

#define FP_WIDTH      ((uint32_t)16)
#define FP_WIDTH_FRAC ((uint32_t)14)
#define FP_WIDTH_INT  (FP_WIDTH - FP_WIDTH_FRAC)

typedef ap_fixed<FP_WIDTH, FP_WIDTH_INT> sample_t;
typedef sample_t coeff_t;
typedef sample_t acc_t;

#endif /* _FM_GLOBAL_HPP */
