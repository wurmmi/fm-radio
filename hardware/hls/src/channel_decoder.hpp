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
                     audio_sample_t& out_audio);

#endif /* _CHANNEL_DECODER_HPP */
