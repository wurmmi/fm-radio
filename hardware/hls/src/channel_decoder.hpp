/*****************************************************************************/
/**
 * @file    channel_decoder.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Channel Decoder IP header.
 */
/*****************************************************************************/

#ifndef _CHANNEL_DECODER_HPP
#define _CHANNEL_DECODER_HPP

#include <hls_stream.h>

#include "fm_global.hpp"

void channel_decoder(hls::stream<sample_t>& in_sample,
                     sample_t& out_audio_L,
                     sample_t& out_audio_R);

#endif /* _CHANNEL_DECODER_HPP */
