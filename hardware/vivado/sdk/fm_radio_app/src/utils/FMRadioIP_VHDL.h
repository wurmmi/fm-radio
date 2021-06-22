/**
 * @file    FMRadioIP_VHDL.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _FMRADIOIP_VHDL_H_
#define _FMRADIOIP_VHDL_H_

#include <string>

#include "FMRadioIP.h"
#include "fm_receiver_vhdl.h"

class FMRadioIP_VHDL : FMRadioIP {
 private:
  fm_radio_t* mDev;

 public:
  FMRadioIP_VHDL(uint32_t device_id);
  ~FMRadioIP_VHDL();

  bool Initialize() override;
  void LED_SetOn(TLed led) override;
  void LED_Toggle(TLed led) override;
  void LED_SetOff(TLed led) override;

  std::string GetGitHash() override;
  std::string GetBuildTime() override;

  void SetMode(TMode mode) override;
  TMode GetMode() override;
};

#endif /* _FMRADIOIP_VHDL_H_ */
