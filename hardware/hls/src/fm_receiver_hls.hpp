/*****************************************************************************/
/**
 * @file    fm_receiver_hls.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver top-level wrapper header.
 */
/*****************************************************************************/

#ifndef _FM_RECEIVER_HLS_HPP
#define _FM_RECEIVER_HLS_HPP

// clang-format off
#include "fm_global.hpp"
// clang-format on

#include <ap_int.h>
#include <hls_stream.h>

#define NUM_LEDS 4

#define REG_STATUS_GIT_HASH_STRLEN   ((uint8_t)8)
#define REG_STATUS_BUILD_TIME_STRLEN ((uint8_t)12)

typedef ap_uint<REG_STATUS_GIT_HASH_STRLEN * 4> status_git_hash_t;
typedef ap_uint<REG_STATUS_BUILD_TIME_STRLEN * 4> status_build_time_t;

typedef struct {
  ap_int<NUM_LEDS> led_ctrl;
  uint8_t enable_fm_radio_ip;
} config_t;

typedef struct {
  status_git_hash_t git_hash;
  status_build_time_t build_time;
} status_t;

void fm_receiver_hls(hls::stream<iq_sample_t>& iq_in,
                     hls::stream<audio_sample_t>& audio_out,
                     config_t& config,
                     status_t* status,
                     ap_int<NUM_LEDS>* led_out);

#endif /* _FM_RECEIVER_HLS_HPP */
