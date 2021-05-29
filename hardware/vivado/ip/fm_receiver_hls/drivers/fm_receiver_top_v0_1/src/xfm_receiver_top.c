// ==============================================================
// File generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and
// SystemC Version: 2018.2 Copyright (C) 1986-2018 Xilinx, Inc. All Rights
// Reserved.
//
// ==============================================================

/***************************** Include Files *********************************/
#include "xfm_receiver_top.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XFm_receiver_top_CfgInitialize(XFm_receiver_top *InstancePtr,
                                   XFm_receiver_top_Config *ConfigPtr) {
  Xil_AssertNonvoid(InstancePtr != NULL);
  Xil_AssertNonvoid(ConfigPtr != NULL);

  InstancePtr->Config_BaseAddress = ConfigPtr->Config_BaseAddress;
  InstancePtr->IsReady            = XIL_COMPONENT_IS_READY;

  return XST_SUCCESS;
}
#endif

void XFm_receiver_top_Set_led_ctrl(XFm_receiver_top *InstancePtr, u32 Data) {
  Xil_AssertVoid(InstancePtr != NULL);
  Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

  XFm_receiver_top_WriteReg(InstancePtr->Config_BaseAddress,
                            XFM_RECEIVER_TOP_CONFIG_ADDR_LED_CTRL_DATA,
                            Data);
}

u32 XFm_receiver_top_Get_led_ctrl(XFm_receiver_top *InstancePtr) {
  u32 Data;

  Xil_AssertNonvoid(InstancePtr != NULL);
  Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

  Data = XFm_receiver_top_ReadReg(InstancePtr->Config_BaseAddress,
                                  XFM_RECEIVER_TOP_CONFIG_ADDR_LED_CTRL_DATA);
  return Data;
}
