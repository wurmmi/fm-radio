/*****************************************************************************/
/**
 * @file    recover_lrdiff.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Recover LR Diff IP header.
 */
/*****************************************************************************/

#ifndef _RECOVER_LRDIFF_HPP
#define _RECOVER_LRDIFF_HPP

#include "fm_global.hpp"

void recover_lrdiff(sample_t const& in_sample,
                    sample_t& in_carrier_38k,
                    sample_t& out_lrdiff);

#endif /* _RECOVER_LRDIFF_HPP */
