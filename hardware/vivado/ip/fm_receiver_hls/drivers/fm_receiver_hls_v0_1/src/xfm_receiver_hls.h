// ==============================================================
// File generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2018.2
// Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
// 
// ==============================================================

#ifndef XFM_RECEIVER_HLS_H
#define XFM_RECEIVER_HLS_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xfm_receiver_hls_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
#else
typedef struct {
    u16 DeviceId;
    u32 Config_BaseAddress;
} XFm_receiver_hls_Config;
#endif

typedef struct {
    u32 Config_BaseAddress;
    u32 IsReady;
} XFm_receiver_hls;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XFm_receiver_hls_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XFm_receiver_hls_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XFm_receiver_hls_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XFm_receiver_hls_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
int XFm_receiver_hls_Initialize(XFm_receiver_hls *InstancePtr, u16 DeviceId);
XFm_receiver_hls_Config* XFm_receiver_hls_LookupConfig(u16 DeviceId);
int XFm_receiver_hls_CfgInitialize(XFm_receiver_hls *InstancePtr, XFm_receiver_hls_Config *ConfigPtr);
#else
int XFm_receiver_hls_Initialize(XFm_receiver_hls *InstancePtr, const char* InstanceName);
int XFm_receiver_hls_Release(XFm_receiver_hls *InstancePtr);
#endif


void XFm_receiver_hls_Set_led_ctrl(XFm_receiver_hls *InstancePtr, u32 Data);
u32 XFm_receiver_hls_Get_led_ctrl(XFm_receiver_hls *InstancePtr);
u32 XFm_receiver_hls_Get_git_hash_BaseAddress(XFm_receiver_hls *InstancePtr);
u32 XFm_receiver_hls_Get_git_hash_HighAddress(XFm_receiver_hls *InstancePtr);
u32 XFm_receiver_hls_Get_git_hash_TotalBytes(XFm_receiver_hls *InstancePtr);
u32 XFm_receiver_hls_Get_git_hash_BitWidth(XFm_receiver_hls *InstancePtr);
u32 XFm_receiver_hls_Get_git_hash_Depth(XFm_receiver_hls *InstancePtr);
u32 XFm_receiver_hls_Write_git_hash_Words(XFm_receiver_hls *InstancePtr, int offset, int *data, int length);
u32 XFm_receiver_hls_Read_git_hash_Words(XFm_receiver_hls *InstancePtr, int offset, int *data, int length);
u32 XFm_receiver_hls_Write_git_hash_Bytes(XFm_receiver_hls *InstancePtr, int offset, char *data, int length);
u32 XFm_receiver_hls_Read_git_hash_Bytes(XFm_receiver_hls *InstancePtr, int offset, char *data, int length);
u32 XFm_receiver_hls_Get_build_time_BaseAddress(XFm_receiver_hls *InstancePtr);
u32 XFm_receiver_hls_Get_build_time_HighAddress(XFm_receiver_hls *InstancePtr);
u32 XFm_receiver_hls_Get_build_time_TotalBytes(XFm_receiver_hls *InstancePtr);
u32 XFm_receiver_hls_Get_build_time_BitWidth(XFm_receiver_hls *InstancePtr);
u32 XFm_receiver_hls_Get_build_time_Depth(XFm_receiver_hls *InstancePtr);
u32 XFm_receiver_hls_Write_build_time_Words(XFm_receiver_hls *InstancePtr, int offset, int *data, int length);
u32 XFm_receiver_hls_Read_build_time_Words(XFm_receiver_hls *InstancePtr, int offset, int *data, int length);
u32 XFm_receiver_hls_Write_build_time_Bytes(XFm_receiver_hls *InstancePtr, int offset, char *data, int length);
u32 XFm_receiver_hls_Read_build_time_Bytes(XFm_receiver_hls *InstancePtr, int offset, char *data, int length);

#ifdef __cplusplus
}
#endif

#endif
