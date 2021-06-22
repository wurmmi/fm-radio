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
enum class TMode : uint32_t { FMRADIO, PASSTHROUGH };

class FMRadioIP {
 protected:
  uint32_t mDeviceId;

  std::string UintToHexString(uint64_t num) const;

 public:
  FMRadioIP(uint32_t device_id);
  ~FMRadioIP();

  virtual bool Initialize()         = 0;
  virtual void LED_SetOn(TLed led)  = 0;
  virtual void LED_Toggle(TLed led) = 0;
  virtual void LED_SetOff(TLed led) = 0;

  virtual void PrintInfo();
  virtual std::string GetGitHash()   = 0;
  virtual std::string GetBuildTime() = 0;

  virtual void SetMode(TMode mode) = 0;
  virtual TMode GetMode()          = 0;
};

#endif /* _FMRADIOIP_H_ */
