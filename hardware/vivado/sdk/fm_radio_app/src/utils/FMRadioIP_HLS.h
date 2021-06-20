/**
 * @file    FMRadioIP_HLS.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _FMRADIOIP_HLS_H_
#define _FMRADIOIP_HLS_H_

#include <string>

#include "FMRadioIP.h"
#include "xfm_receiver_hls.h"

class FMRadioIP_HLS : FMRadioIP {
 private:
  XFm_receiver_hls mDev;

 public:
  FMRadioIP_HLS(uint32_t device_id);
  ~FMRadioIP_HLS();

  bool Initialize() override;
  void LED_SetOn(TLed led) override;
  void LED_Toggle(TLed led) override;
  void LED_SetOff(TLed led) override;

  std::string GetGitHash() override;
  std::string GetBuildTime() override;

  void SetMode(TMode mode) override;
  TMode GetMode() override;
};

#endif /* _FMRADIOIP_HLS_H_ */
