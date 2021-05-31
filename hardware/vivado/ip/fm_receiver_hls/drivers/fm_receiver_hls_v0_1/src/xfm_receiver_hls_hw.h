// ==============================================================
// File generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2018.2
// Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
// 
// ==============================================================

// CONFIG
// 0x00 : reserved
// 0x04 : reserved
// 0x08 : reserved
// 0x0c : reserved
// 0x10 : Data signal of led_ctrl
//        bit 7~0 - led_ctrl[7:0] (Read/Write)
//        others  - reserved
// 0x14 : reserved
// 0x18 ~
// 0x1f : Memory 'git_hash' (7 * 8b)
//        Word n : bit [ 7: 0] - git_hash[4n]
//                 bit [15: 8] - git_hash[4n+1]
//                 bit [23:16] - git_hash[4n+2]
//                 bit [31:24] - git_hash[4n+3]
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XFM_RECEIVER_HLS_CONFIG_ADDR_LED_CTRL_DATA 0x10
#define XFM_RECEIVER_HLS_CONFIG_BITS_LED_CTRL_DATA 8
#define XFM_RECEIVER_HLS_CONFIG_ADDR_GIT_HASH_BASE 0x18
#define XFM_RECEIVER_HLS_CONFIG_ADDR_GIT_HASH_HIGH 0x1f
#define XFM_RECEIVER_HLS_CONFIG_WIDTH_GIT_HASH     8
#define XFM_RECEIVER_HLS_CONFIG_DEPTH_GIT_HASH     7

