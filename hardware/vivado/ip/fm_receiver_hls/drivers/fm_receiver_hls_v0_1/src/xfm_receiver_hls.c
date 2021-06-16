// ==============================================================
// File generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2018.2
// Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
// 
// ==============================================================

/***************************** Include Files *********************************/
#include "xfm_receiver_hls.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XFm_receiver_hls_CfgInitialize(XFm_receiver_hls *InstancePtr, XFm_receiver_hls_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Api_BaseAddress = ConfigPtr->Api_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XFm_receiver_hls_Set_config_led_ctrl(XFm_receiver_hls *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFm_receiver_hls_WriteReg(InstancePtr->Api_BaseAddress, XFM_RECEIVER_HLS_API_ADDR_CONFIG_LED_CTRL_DATA, Data);
}

u32 XFm_receiver_hls_Get_config_led_ctrl(XFm_receiver_hls *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFm_receiver_hls_ReadReg(InstancePtr->Api_BaseAddress, XFM_RECEIVER_HLS_API_ADDR_CONFIG_LED_CTRL_DATA);
    return Data;
}

void XFm_receiver_hls_Set_config_enable_fm_radio_ip(XFm_receiver_hls *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFm_receiver_hls_WriteReg(InstancePtr->Api_BaseAddress, XFM_RECEIVER_HLS_API_ADDR_CONFIG_ENABLE_FM_RADIO_IP_DATA, Data);
}

u32 XFm_receiver_hls_Get_config_enable_fm_radio_ip(XFm_receiver_hls *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFm_receiver_hls_ReadReg(InstancePtr->Api_BaseAddress, XFM_RECEIVER_HLS_API_ADDR_CONFIG_ENABLE_FM_RADIO_IP_DATA);
    return Data;
}

u32 XFm_receiver_hls_Get_status_git_hash_V(XFm_receiver_hls *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFm_receiver_hls_ReadReg(InstancePtr->Api_BaseAddress, XFM_RECEIVER_HLS_API_ADDR_STATUS_GIT_HASH_V_DATA);
    return Data;
}

u64 XFm_receiver_hls_Get_status_build_time_V(XFm_receiver_hls *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFm_receiver_hls_ReadReg(InstancePtr->Api_BaseAddress, XFM_RECEIVER_HLS_API_ADDR_STATUS_BUILD_TIME_V_DATA);
    Data += (u64)XFm_receiver_hls_ReadReg(InstancePtr->Api_BaseAddress, XFM_RECEIVER_HLS_API_ADDR_STATUS_BUILD_TIME_V_DATA + 4) << 32;
    return Data;
}

