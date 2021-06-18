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
templates = ./script/utils/register_engine.py ./spec/$1.yaml ./script/utils/ip/templates/$2 $3

registers = \
	@echo "Generating registers for $1..."; \
	$(if $(shell test -f ./src/ip/$1/src/spec/$1.yaml && echo file exists), \
			$(call templates,$1,registers_axi.vhd,./src/ip/$1/src/rtl/$1_axi.vhd); \
			$(call templates,$1,registers_pkg.vhd,./src/ip/$1/src/tb/$1_reg_pkg.vhd); \
			$(call templates,$1,registers.md,./src/ip/$1/registers.md); \
			$(call templates,$1,spec.vhd,./src/ip/$1/src/rtl/$1_spec_pkg.vhd); \
			$(call templates,$1,registers.h,./src/ip/$1/src/include/$1.h), \
		echo "Could not find specification file 'src/ip/$1/src/spec/$1.yaml'")


##==============================================================================
##Makefile Help for FM Receiver.
##==============================================================================
##
##Supported Targets
##-----------------

registers: ##	- Generate IP register files from templates.
	$(call registers,))

clean: ##			- Clean all outputs.
	@echo "Cleaning..."
	git clean -xdf

help: ##				- Show this help message.
	@grep -h "##" Makefile | grep -v "\"##\"" | sed -e 's/##//g'

.PHONY: clean help

##
##==============================================================================
