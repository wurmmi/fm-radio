/**
 * @file    ADAU1761.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "ADAU1761.h"

#include <iostream>

using namespace std;

ADAU1761::ADAU1761() : mConfigFifo(XPAR_AXI_FIFO_MM_S_1_DEVICE_ID) {}
ADAU1761::~ADAU1761() {}

bool ADAU1761::adau1761_chip_config() {
  cout << "read 0" << endl;
  // Enable SPI mode
  mConfigFifo.read(0x4000);
  mConfigFifo.read(0x4000);
  mConfigFifo.read(0x4000);

  cout << "write 0" << endl;
  // Enable clock
  mConfigFifo.write(0x4000, 0x01);

  cout << "write 1" << endl;
  // SLEWPD=1, ALCPD=1, DECPD=1, SOUTPD=1, INTPD=1, SINPD=1, SPPD=1
  mConfigFifo.write(0x40F9, 0x7F);
  // CLK1=0, CLK0=1
  mConfigFifo.write(0x40FA, 0x01);

  // MX3LM=1, MX3RM=0, MX3G1=0, MX3G2=0, MX3AUXG=0, MX5G3=3, MX6G3=0, LOUTVOL=63
  // MX4LM=0, MX4RM=1, MX4G1=0, MX4G2=0, MX4AUXG=0, MX5G4=0, MX6G4=3, ROUTVOL=63

  // LRCLK/LRPOL=falling edge, LRCLK/LRMOD=50%, BCLK/BPOL=falloing edge, LRDEL=1
  // SPSRS=0, LRMOD=0, BPOL=0, LRPOL=0, CHPF=0, MS=0
  mConfigFifo.write(0x4015, 0x00);
  // BPF=0, ADTDM=0, DATDM=0, MSBP=0, LRDEL=0
  mConfigFifo.write(0x4016, 0x00);
  // DAPAIR=0, DAOSR=0, ADOSR=0, CONVSR=0
  mConfigFifo.write(0x4017, 0x00);
  // MX3RM=0, MX3LM=1, MX3AUXG=0, MX3EN=1
  mConfigFifo.write(0x401C, 0x21);
  // MX3G2=0, MX3G1=0
  mConfigFifo.write(0x401D, 0x00);
  // MX4RM=1, MX4LM=0, MX4AUXG=0, MX4EN=1
  mConfigFifo.write(0x401E, 0x41);
  // MX4G2=0, MX4G1=0
  mConfigFifo.write(0x401F, 0x00);
  // MX5G4=0, MX5G3=10, MX5EN=1
  mConfigFifo.write(0x4020, 0x05);
  // MX6G4=01, MX6G3=0, MX6EN=1
  mConfigFifo.write(0x4021, 0x11);
  // MX7=0, MX7EN=0
  mConfigFifo.write(0x4022, 0x00);
  // LOUTVOL=63, LOUTM=1, LOMODE=0
  mConfigFifo.write(0x4025, 0xFE);
  // ROUTVOL=63, ROUTM=1, ROMODE=0
  mConfigFifo.write(0x4026, 0xFE);

  // HPBIAS=0, DACBIAS=0, PBIAS=0, PREN=1, PLEN=1
  mConfigFifo.write(0x4029, 0x03);
  // DACMONO=0, DACPOL=0,DEMPH=0, DACEN=3
  mConfigFifo.write(0x402A, 0x03);

  // SINRT=1
  mConfigFifo.write(0x40F2, 0x01);

  // Check initialization status
  uint8_t rdata = mConfigFifo.read(0x4000);
  if (rdata != 0x01) {
    cerr << "ERROR in ADAU1761 initialization." << endl;
    return false;
  }

  return true;
}

bool ADAU1761::Initialize() {
  cout << "Configuring the config-FIFO ..." << endl;
  // Configure config FIFO
  int status = mConfigFifo.Initialize();
  if (!status)
    return false;
  cout << "Done" << endl;

  cout << "Configuring the ADAU1761 chip ..." << endl;
  // Configure ADAU1761 chip
  status = adau1761_chip_config();
  if (!status)
    return false;
  cout << "Done" << endl;

  return true;
}
