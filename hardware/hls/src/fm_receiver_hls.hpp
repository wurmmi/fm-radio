/*****************************************************************************/
/**
 * @file    fm_receiver_hls.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver top-level wrapper header.
 */
/*****************************************************************************/

#ifndef _FM_RECEIVER_HLS_HPP
#define _FM_RECEIVER_HLS_HPP

#include <ap_int.h>
#include <hls_stream.h>

#include "fm_global.hpp"

#define REG_STATUS_GIT_HASH_STRLEN   ((uint8_t)7)
#define REG_STATUS_BUILD_TIME_STRLEN ((uint8_t)12)

typedef struct {
  sample_t L;
  sample_t R;
} audio_sample_t;

typedef ap_uint<REG_STATUS_GIT_HASH_STRLEN * 4> status_git_hash_t;
typedef ap_uint<REG_STATUS_BUILD_TIME_STRLEN * 4> status_build_time_t;

void fm_receiver_hls(hls::stream<iq_sample_t>& iq_in,
                     hls::stream<audio_sample_t>& audio_out,
                     uint8_t led_ctrl,
                     status_git_hash_t* status_git_hash,
                     status_build_time_t* status_build_time,
                     uint8_t* led_out);

#endif /* _FM_RECEIVER_HLS_HPP */
