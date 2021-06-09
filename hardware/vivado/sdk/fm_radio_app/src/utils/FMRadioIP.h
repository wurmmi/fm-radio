/**
 * @file    FMRadioIP.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _FMRADIOIP_H_
#define _FMRADIOIP_H_

#include <string>

#include "xfm_receiver_hls.h"

enum class TLed { LED1, LED2, LED3, LED4, LED5, LED6, LED7, ALL };

class FMRadioIP {
 private:
  XFm_receiver_hls mDev;
  uint32_t mDeviceId;

  std::string UintToHexString(uint64_t num);

 public:
  FMRadioIP(uint32_t device_id);
  ~FMRadioIP();

  bool Initialize();
  void LED_SetOn(TLed led);
  void LED_Toggle(TLed led);
  void LED_SetOff(TLed led);

  std::string GetGitHash();
  std::string GetBuildTime();
};

#endif /* _FMRADIOIP_H_ */
