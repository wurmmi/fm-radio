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
VHDL_SOURCES += $(CURDIR)/../../rtl/packages/fm_radio_spec_pkg.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/packages/fm_global_spec_pkg.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/fm_global_pkg.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/packages/filter_lp_mono_pkg.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/packages/filter_bp_pilot_pkg.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/packages/filter_bp_lrdiff_pkg.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/utils/delay_bit.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/utils/delay_vector.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/utils/DspFir.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/utils/decimator.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/utils/strobe_gen.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/channel_decoder/recover_carriers.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/channel_decoder/recover_lrdiff.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/channel_decoder/recover_mono.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/channel_decoder/separate_lr_audio.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/channel_decoder.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/fm_demodulator.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/fm_receiver.vhd
VHDL_SOURCES += $(CURDIR)/../../rtl/fm_receiver_top.vhd

# Set toplevel module in VHDL
TOPLEVEL = fm_receiver_top

# Set python testbench filename
MODULE = tests

include $(shell cocotb-config --makefiles)/Makefile.sim

wave:
ifeq ($(USE_WAVE_VCD),1)
		gtkwave sim_build/waveform.vcd gtkwave/waveconfig_vcd.gtkw
else
		gtkwave sim_build/waveform.ghw gtkwave/waveconfig.gtkw
endif

reload_python_plots:
	@python -c """\
	from helpers import reload_all_plots_pickle; \
	reload_all_plots_pickle('sim_build')\
	"""

.PHONY: wave
