/*****************************************************************************/
/**
 * @file    fm_receiver_top.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver top-level wrapper header.
 */
/*****************************************************************************/

#ifndef _FM_RECEIVER_TOP_HPP
#define _FM_RECEIVER_TOP_HPP

#include <hls_stream.h>

#include "fm_global.hpp"

typedef struct {
  sample_t L;
  sample_t R;
} audio_sample_t;

void fm_receiver_top(hls::stream<iq_sample_t>& iq_in,
                     hls::stream<audio_sample_t>& audio_out);

#endif /* _FM_RECEIVER_TOP_HPP */
