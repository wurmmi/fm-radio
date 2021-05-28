// ==============================================================
// File generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2018.2
// Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
// 
// ==============================================================

#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xfm_receiver_top.h"

extern XFm_receiver_top_Config XFm_receiver_top_ConfigTable[];

XFm_receiver_top_Config *XFm_receiver_top_LookupConfig(u16 DeviceId) {
	XFm_receiver_top_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XFM_RECEIVER_TOP_NUM_INSTANCES; Index++) {
		if (XFm_receiver_top_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XFm_receiver_top_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XFm_receiver_top_Initialize(XFm_receiver_top *InstancePtr, u16 DeviceId) {
	XFm_receiver_top_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XFm_receiver_top_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XFm_receiver_top_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

