/*
 * Copyright (C) 2017-2021 Michael Wurm
 * Author: Super Easy Register Scripting Engine (SERSE)
 *
 *
 *  This file is generated by SERSE.
 *  *** DO NOT MODIFY ***
 */

/* FM Radio register map */

#ifndef FM_RADIO_H
#define FM_RADIO_H

#include <stdint.h>

/* FM Radio AXI-Lite base address */
#define FM_RADIO_BASE ((fm_radio_t *)0xDEADBEEF)

/* FM Radio register structure */
typedef struct {
  const volatile uint32_t MAGIC_VALUE;
        volatile uint32_t LED_CONTROL;
        volatile uint32_t ENABLE_FM_RADIO;
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
#define FM_LED_CONTROL_VALUE_Len (4U)
#define FM_LED_CONTROL_VALUE_Rst (0x0U)
#define FM_LED_CONTROL_VALUE_Msk \
    (0xFU << FM_LED_CONTROL_VALUE_Pos)
#define GET_FM_LED_CONTROL_VALUE(REG) \
    (((REG) & FM_LED_CONTROL_VALUE_Msk) >> FM_LED_CONTROL_VALUE_Pos)
#define SET_FM_LED_CONTROL_VALUE(REG, VAL) \
    (((REG) & ~FM_LED_CONTROL_VALUE_Msk) | ((VAL) << FM_LED_CONTROL_VALUE_Pos))

/* Register: FM_ENABLE_FM_RADIO */
#define FM_ENABLE_FM_RADIO_VALUE_Pos (0U)
#define FM_ENABLE_FM_RADIO_VALUE_Len (1U)
#define FM_ENABLE_FM_RADIO_VALUE_Rst (0x1U)
#define FM_ENABLE_FM_RADIO_VALUE_Msk \
    (0x1U << FM_ENABLE_FM_RADIO_VALUE_Pos)
#define GET_FM_ENABLE_FM_RADIO_VALUE(REG) \
    (((REG) & FM_ENABLE_FM_RADIO_VALUE_Msk) >> FM_ENABLE_FM_RADIO_VALUE_Pos)
#define SET_FM_ENABLE_FM_RADIO_VALUE(REG, VAL) \
    (((REG) & ~FM_ENABLE_FM_RADIO_VALUE_Msk) | ((VAL) << FM_ENABLE_FM_RADIO_VALUE_Pos))

#endif /* FM_RADIO_H */
