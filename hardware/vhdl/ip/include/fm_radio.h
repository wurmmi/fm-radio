/*
 * Copyright (C) 2017-2021 Michael Wurm
 * Author: Super Easy Register Scripting Engine (SERSE)
 *
/* FM Radio register map */

#ifndef FM_RADIO_H
#define FM_RADIO_H

#include <stdint.h>

/* FM Radio AXI-Lite base address */
#define FM_RADIO_BASE ((fm_radio_t *)0x40300000)

/* FM Radio register structure */
typedef struct {
  const volatile u32 MAGIC_VALUE;
        volatile u32 LED_CONTROL;
} fm_radio_t;

/* Register: FM_MAGIC_VALUE */
#define FM_MAGIC_VALUE_VALUE_Pos (0U)
#define FM_MAGIC_VALUE_VALUE_Len (32U)
#define FM_MAGIC_VALUE_VALUE_Rst (0xDEADBEEFU)
#define FM_MAGIC_VALUE_VALUE_Msk \
    (0xFFFFFFFFU << FM_MAGIC_VALUE_VALUE_Pos)
#define GET_FM_MAGIC_VALUE_VALUE(REG) \
    (((REG) & FM_MAGIC_VALUE_VALUE_Msk) >> FM_MAGIC_VALUE_VALUE_Pos)

/* Register: FM_LED_CONTROL */
#define FM_LED_CONTROL_VALUE_Pos (0U)
#define FM_LED_CONTROL_VALUE_Len (8U)
#define FM_LED_CONTROL_VALUE_Rst (0x0U)
#define FM_LED_CONTROL_VALUE_Msk \
    (0xFFU << FM_LED_CONTROL_VALUE_Pos)
#define GET_FM_LED_CONTROL_VALUE(REG) \
    (((REG) & FM_LED_CONTROL_VALUE_Msk) >> FM_LED_CONTROL_VALUE_Pos)
#define SET_FM_LED_CONTROL_VALUE(REG, VAL) \
    (((REG) & ~FM_LED_CONTROL_VALUE_Msk) | ((VAL) << FM_LED_CONTROL_VALUE_Pos))

#endif /* FM_RADIO_H */
