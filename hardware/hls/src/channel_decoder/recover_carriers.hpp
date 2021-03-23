/*****************************************************************************/
/**
 * @file    recover_carriers.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Recover Carriers IP header.
 */
/*****************************************************************************/

#ifndef _RECOVER_CARRIERS_HPP
#define _RECOVER_CARRIERS_HPP

#include "fm_global.hpp"

void recover_carriers(sample_t const& in_sample,
                      sample_t& out_carrier_38k,
                      sample_t& out_carrier_57k);

#endif /* _RECOVER_CARRIERS_HPP */