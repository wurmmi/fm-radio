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

void fm_receiver(sample_t in_i,
                 sample_t in_q,
                 sample_t &audio_L,
                 sample_t &audio_R);

#endif /* _FM_RECEIVER_HPP */
