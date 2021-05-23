/**
 * @file    adau1761.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "adau1761.h"

#include <iostream>

using namespace std;

adau1761::adau1761() {}

adau1761::~adau1761() {}

uint8_t adau1761::read_spi(uint16_t addr) {
  XLlFifo* dev = &mDevConfig.fifo_spi;

  XLlFifo_TxPutWord(dev, ((mDevConfig.chipAddr << 1) | 0x01) & 0xFF);
  XLlFifo_TxPutWord(dev, (addr >> 8) & 0xFF);
  XLlFifo_TxPutWord(dev, addr & 0xFF);
  XLlFifo_TxPutWord(dev, 0);
  XLlFifo_iTxSetLen(dev, 4 * mDevConfig.wordSize);
  while (XLlFifo_RxOccupancy(dev) != 4) {
  }
  XLlFifo_RxGetWord(dev);
  XLlFifo_RxGetWord(dev);
  XLlFifo_RxGetWord(dev);
  uint32_t rdata = XLlFifo_RxGetWord(dev);

  return (uint8_t)(rdata & 0xFF);
}

void adau1761::write_spi(uint16_t addr, uint8_t value) {
  XLlFifo* dev = &mDevConfig.fifo_spi;

  XLlFifo_TxPutWord(dev, (mDevConfig.chipAddr << 1) & 0xFF);
  XLlFifo_TxPutWord(dev, (addr >> 8) & 0xFF);
  XLlFifo_TxPutWord(dev, addr & 0xFF);
  XLlFifo_TxPutWord(dev, value);
  XLlFifo_iTxSetLen(dev, 4 * mDevConfig.wordSize);
  while (XLlFifo_RxOccupancy(dev) != 4) {
  }
  XLlFifo_RxGetWord(dev);
  XLlFifo_RxGetWord(dev);
  XLlFifo_RxGetWord(dev);
  XLlFifo_RxGetWord(dev);
}

void adau1761::write_i2s(uint16_t left, uint16_t right) {
  while (!XLlFifo_iTxVacancy(&mDevConfig.fifo_i2s)) {
    // Don't do this in an interrupt routine...
    // printf("I2S FIFO full. Waiting ... \n");
  }
  XLlFifo_TxPutWord(&mDevConfig.fifo_i2s, ((u32)left << 16) | (u32)right);
  XLlFifo_iTxSetLen(&mDevConfig.fifo_i2s, 1 * mDevConfig.wordSize);
}

bool adau1761::init_fifos() {
  // Initialize FIFO 0
  XLlFifo_Config* pFIFO_0_Config =
      XLlFfio_LookupConfig(XPAR_AXI_FIFO_MM_S_0_DEVICE_ID);
  int status = XLlFifo_CfgInitialize(
      &mDevConfig.fifo_spi, pFIFO_0_Config, pFIFO_0_Config->BaseAddress);
  if (status != XST_SUCCESS) {
    cerr << "Could not initialize FIFO 0" << endl;
    return false;
  }

  // Check FIFO 0 status and clear interrupts
  status = XLlFifo_Status(&mDevConfig.fifo_spi);
  // if (status != XST_SUCCESS) {
  //  printf("Status of FIFO 0 not okay. (status = %x)\n", status);
  //  return false;
  //}
  printf("Clearing interrupts of FIFO 0\n");
  XLlFifo_IntClear(&mDevConfig.fifo_spi, 0xffffffff);

  status = XLlFifo_Status(&mDevConfig.fifo_spi);
  if (status != XST_SUCCESS) {
    printf("Status of FIFO 0 not okay. (status = %x)\n", status);
    return false;
  }

  // Initialize FIFO 1
  XLlFifo_Config* pFIFO_1_Config =
      XLlFfio_LookupConfig(XPAR_AXI_FIFO_MM_S_1_DEVICE_ID);
  status = XLlFifo_CfgInitialize(
      &mDevConfig.fifo_i2s, pFIFO_1_Config, pFIFO_1_Config->BaseAddress);
  if (status != XST_SUCCESS) {
    cerr << "Could not initialize FIFO 1" << endl;
    return false;
  }

  // Check FIFO 1 status and clear interrupts
  status = XLlFifo_Status(&mDevConfig.fifo_i2s);
  // if (status != XST_SUCCESS) {
  //  printf("Status of FIFO 1 not okay. (status = %x)\n", status);
  //  return false;
  //}
  printf("Clearing interrupts of FIFO 1\n");
  XLlFifo_IntClear(&mDevConfig.fifo_i2s, 0xffffffff);

  status = XLlFifo_Status(&mDevConfig.fifo_i2s);
  if (status != XST_SUCCESS) {
    printf("Status of FIFO 1 not okay. (status = %x)\n", status);
    return false;
  }

  return true;
}

bool adau1761::init_adau1761() {
  // Enable SPI mode
  read_spi(0x4000);
  read_spi(0x4000);
  read_spi(0x4000);

  // Enable clock
  write_spi(0x4000, 0x01);

  // SLEWPD=1, ALCPD=1, DECPD=1, SOUTPD=1, INTPD=1, SINPD=1, SPPD=1
  write_spi(0x40F9, 0x7F);
  // CLK1=0, CLK0=1
  write_spi(0x40FA, 0x01);

  // MX3LM=1, MX3RM=0, MX3G1=0, MX3G2=0, MX3AUXG=0, MX5G3=3, MX6G3=0, LOUTVOL=63
  // MX4LM=0, MX4RM=1, MX4G1=0, MX4G2=0, MX4AUXG=0, MX5G4=0, MX6G4=3, ROUTVOL=63

  // LRCLK/LRPOL=falling edge, LRCLK/LRMOD=50%, BCLK/BPOL=falloing edge, LRDEL=1
  // SPSRS=0, LRMOD=0, BPOL=0, LRPOL=0, CHPF=0, MS=0
  write_spi(0x4015, 0x00);
  // BPF=0, ADTDM=0, DATDM=0, MSBP=0, LRDEL=0
  write_spi(0x4016, 0x00);
  // DAPAIR=0, DAOSR=0, ADOSR=0, CONVSR=0
  write_spi(0x4017, 0x00);
  // MX3RM=0, MX3LM=1, MX3AUXG=0, MX3EN=1
  write_spi(0x401C, 0x21);
  // MX3G2=0, MX3G1=0
  write_spi(0x401D, 0x00);
  // MX4RM=1, MX4LM=0, MX4AUXG=0, MX4EN=1
  write_spi(0x401E, 0x41);
  // MX4G2=0, MX4G1=0
  write_spi(0x401F, 0x00);
  // MX5G4=0, MX5G3=10, MX5EN=1
  write_spi(0x4020, 0x05);
  // MX6G4=01, MX6G3=0, MX6EN=1
  write_spi(0x4021, 0x11);
  // MX7=0, MX7EN=0
  write_spi(0x4022, 0x00);
  // LOUTVOL=63, LOUTM=1, LOMODE=0
  write_spi(0x4025, 0xFE);
  // ROUTVOL=63, ROUTM=1, ROMODE=0
  write_spi(0x4026, 0xFE);

  // HPBIAS=0, DACBIAS=0, PBIAS=0, PREN=1, PLEN=1
  write_spi(0x4029, 0x03);
  // DACMONO=0, DACPOL=0,DEMPH=0, DACEN=3
  write_spi(0x402A, 0x03);

  // SINRT=1
  write_spi(0x40F2, 0x01);

  // Check initialization status
  uint8_t rdata = read_spi(0x4000);
  if (rdata != 0x01) {
    cerr << "ERROR in ADAU1761 initialization." << endl;
    return false;
  }

  return true;
}

void adau1761::irq_handler_fifo_callback(void* context) {
  static_cast<adau1761*>(context)->irq_handler_fifo();
}

void adau1761::write_fifo() {
  for (auto const& elem : mDevConfig.fifo_buffer) {
    write_i2s(elem.left, elem.right);
  }
}

void adau1761::irq_handler_fifo() {
  uint32_t pending = XLlFifo_IntPending((&mDevConfig.fifo_i2s));
  while (pending) {
    if (pending & XLLF_INT_RC_MASK) {
      // FifoRecvHandler(InstancePtr);
      XLlFifo_IntClear(&mDevConfig.fifo_i2s, XLLF_INT_RC_MASK);
    } else if (pending & XLLF_INT_TC_MASK) {
      // vacancy1 = XLlFifo_iTxVacancy( (&This->fifo));vacancy1count ++;
      // This->transmitFifo();
      // TxSend2(InstancePtr);
      // cout << "Tx Empty" << endl;
      XLlFifo_IntClear(&mDevConfig.fifo_i2s, XLLF_INT_TC_MASK);
      // XLlFifo_IntClear(&This->fifo, XLLF_INT_TFPE_MASK);
    } else if (pending & XLLF_INT_TFPE_MASK) {
      // vacancy2 = XLlFifo_iTxVacancy( (&This->fifo));vacancy2count ++;
      write_fifo();
      // XLlFifo_IntClear(&This->fifo, XLLF_INT_TC_MASK);
      XLlFifo_IntClear(&mDevConfig.fifo_i2s, XLLF_INT_TFPE_MASK);
    } else if (pending & XLLF_INT_ERROR_MASK) {
      // FifoErrorHandler(InstancePtr, pending);
      XLlFifo_IntClear(&mDevConfig.fifo_i2s, XLLF_INT_ERROR_MASK);
    } else {
      XLlFifo_IntClear(&mDevConfig.fifo_i2s, pending);
    }
    pending = XLlFifo_IntPending(&mDevConfig.fifo_i2s);
  }
}

bool adau1761::setup_fifo_interrupts() {
  // Initialize the interrupt controller driver so that it is ready to use.
  XScuGic_Config* IntcConfig =
      XScuGic_LookupConfig(XPAR_SCUGIC_SINGLE_DEVICE_ID);
  if (IntcConfig == nullptr) {
    printf("XScuGic_LookupConfig() failed\n");
    return false;
  }

  int Status = XScuGic_CfgInitialize(
      &mDevConfig.irqCtrl, IntcConfig, IntcConfig->CpuBaseAddress);
  if (Status != XST_SUCCESS) {
    printf("XScuGic_CfgInitialize() failed\n");
    return false;
  }

  uint32_t irq_id = XPAR_FABRIC_AXI_FIFO_MM_S_1_INTERRUPT_INTR;
  XScuGic_SetPriorityTriggerType(&mDevConfig.irqCtrl, irq_id, 0xA0, 0x03);

  // Connect the device driver handler that will be called when an
  // interrupt for the device occurs, the handler defined above performs
  // the specific interrupt processing for the device.
  Status = XScuGic_Connect(&mDevConfig.irqCtrl,
                           irq_id,
                           (Xil_InterruptHandler)irq_handler_fifo_callback,
                           this);
  if (Status != XST_SUCCESS) {
    printf("XScuGic_Connect() failed\n");
    return false;
  }

  XScuGic_Enable(&mDevConfig.irqCtrl, irq_id);

  // Initialize the exception table.
  Xil_ExceptionInit();

  // Register the interrupt controller handler with the exception table.
  Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                               (Xil_ExceptionHandler)XScuGic_InterruptHandler,
                               (void*)&mDevConfig.irqCtrl);

  // Enable exceptions.
  Xil_ExceptionEnable();

  return true;
}

bool adau1761::initialize() {
  mDevConfig.chipAddr = 0;
  mDevConfig.wordSize = 4;

  bool status = init_fifos();
  if (!status)
    return false;

  status = init_adau1761();
  if (!status)
    return false;

  // FIFO interrupts setup
  setup_fifo_interrupts();

  return true;
}
