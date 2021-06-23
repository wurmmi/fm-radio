#-------------------------------------------------------------------------------
# file:      Makefile
# author:    Michael Wurm <wurm.michael95@gmail.com>
# copyright: 2021 Michael Wurm
# brief:     Makefile for FM Receiver IP (VHDL).
#-------------------------------------------------------------------------------

GUI = 0

# --- Defines ---
SHELL        = /bin/bash
MAKEFILE_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# --- Functions ---
templates = ./script/utils/register_engine.py --rom $1 ./ip/spec/$2.yaml ./script/utils/ip/templates/$3 $4
git_describe = $(shell git describe --always)

registers = \
	@echo "Generating registers ..."; \
	$(if $(shell test -f ./ip/spec/fm_radio.yaml && echo file exists), \
			$(call templates,0,$1,registers_axi.vhd,./ip/rtl/$1_axi.vhd); \
			$(call templates,0,$1,registers.md,./ip/registers.md); \
			$(call templates,0,$1,spec.vhd,./ip/rtl/packages/$1_spec_pkg.vhd); \
			$(call templates,0,$1,registers.h,./ip/drivers/fm_receiver_vhdl_v0_1/src/fm_receiver_vhdl.h); \
			$(call templates,$(git_describe),$1,rom.vhd,./ip/rtl/$1_rom.vhd), \
		echo "Could not find specification file './ip/spec/fm_radio.yaml'")


##==============================================================================
##Makefile Help for FM Receiver.
##==============================================================================
##
##Supported Targets
##-----------------

registers: ##		- Generate IP register files from templates.
	$(call registers,fm_radio)

clean: ##			- Clean all outputs.
	@echo "Cleaning..."
	git clean -xdf

help: ##			- Show this help message.
	@grep -h "##" Makefile | grep -v "\"##\"" | sed -e 's/##//g'

.PHONY: clean help

##
##==============================================================================
