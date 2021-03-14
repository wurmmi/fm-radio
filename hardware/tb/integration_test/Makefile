################################################################################
# File        : Makefile
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Makefile for cocotb testbench
################################################################################

SIM = ghdl
TOPLEVEL_LANG = vhdl

USE_WAVE_VCD = 0

COMPILE_ARGS = --std=08
ifeq ($(USE_WAVE_VCD),1)
	SIM_ARGS = --vcd=sim_build/waveform.vcd --read-wave-opt=gtkwave/waveopt.gtkw
else
	SIM_ARGS = --wave=sim_build/waveform.ghw --read-wave-opt=gtkwave/waveopt.gtkw
endif
#SIM_ARGS +=

# VHDL sources in compile order
VHDL_SOURCES =
VHDL_SOURCES += $(CURDIR)/../../src/fm_pkg.vhd
VHDL_SOURCES += $(CURDIR)/../../src/filter_coeff_pkgs/filter_lp_mono_pkg.vhd
VHDL_SOURCES += $(CURDIR)/../../src/filter_coeff_pkgs/filter_bp_pilot_pkg.vhd
VHDL_SOURCES += $(CURDIR)/../../src/utils/delay_bit.vhd
VHDL_SOURCES += $(CURDIR)/../../src/utils/delay_vector.vhd
VHDL_SOURCES += $(CURDIR)/../../src/utils/DspFir.vhd
VHDL_SOURCES += $(CURDIR)/../../src/utils/decimator.vhd
VHDL_SOURCES += $(CURDIR)/../../src/channel_decoder/recover_carriers.vhd
VHDL_SOURCES += $(CURDIR)/../../src/channel_decoder/recover_lrdiff.vhd
VHDL_SOURCES += $(CURDIR)/../../src/channel_decoder/recover_mono.vhd
VHDL_SOURCES += $(CURDIR)/../../src/channel_decoder/separate_lr_audio.vhd
VHDL_SOURCES += $(CURDIR)/../../src/channel_decoder.vhd
VHDL_SOURCES += $(CURDIR)/../../src/fm_demodulator.vhd
VHDL_SOURCES += $(CURDIR)/../../src/fm_receiver.vhd

# Set toplevel module in VHDL
TOPLEVEL = fm_receiver

# Set python testbench filename
MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim

wave:
ifeq ($(USE_WAVE_VCD),1)
		gtkwave sim_build/waveform.vcd gtkwave/waveconfig_vcd.gtkw
else
		gtkwave sim_build/waveform.ghw gtkwave/waveconfig.gtkw
endif

.PHONY: wave
