/**
 * @file    AxiStreamRouter.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _AXISTREAMROUTER_H_
#define _AXISTREAMROUTER_H_

#include <string>

#include "xaxis_switch.h"

enum class IPSelection { HLS, VHDL };

class AxiStreamRouter {
 private:
  XAxis_Switch mAxisSwitchIn;
  XAxis_Switch mAxisSwitchOut;
  IPSelection mCurrentSelection;

  bool Initialize();

 public:
  AxiStreamRouter();
  ~AxiStreamRouter();

  void SelectIP(IPSelection selection);
  IPSelection GetCurrentlySelectedIP();
  void ConfigureAxiSwitch(u8 parallel_ip_nr);
};

#endif /* _AXISTREAMROUTER_H_ */
