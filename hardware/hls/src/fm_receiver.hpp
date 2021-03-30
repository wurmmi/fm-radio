/*****************************************************************************/
/**
 * @file    fm_receiver.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver IP header.
 */
/*****************************************************************************/

#ifndef _FM_RECEIVER_HPP
#define _FM_RECEIVER_HPP

#include "fm_global.hpp"

typedef struct {
  sample_t i;
  sample_t q;
} iq_sample_t;

void fm_receiver(iq_sample_t const& sample_in,
                 sample_t& out_audio_L,
                 sample_t& out_audio_R);

#endif /* _FM_RECEIVER_HPP */
