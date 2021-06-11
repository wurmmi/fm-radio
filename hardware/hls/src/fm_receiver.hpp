/*****************************************************************************/
/**
 * @file    fm_receiver.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver IP header.
 */
/*****************************************************************************/

#ifndef _FM_RECEIVER_HPP
#define _FM_RECEIVER_HPP

#include <hls_stream.h>

#include "fm_global.hpp"

void fm_receiver(hls::stream<iq_sample_t>& iq_in,
                 sample_t& out_audio_L,
                 sample_t& out_audio_R);

#endif /* _FM_RECEIVER_HPP */
