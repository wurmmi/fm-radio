#-------------------------------------------------------------------------------
# file:      Makefile
# author:    Michael Wurm <wurm.michael95@gmail.com>
# copyright: 2021 Michael Wurm
# brief:     Makefile for Vivado project.
#-------------------------------------------------------------------------------

GUI = 0

SHELL        = /bin/bash
MAKEFILE_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

VIVADO_DIR = ./generated
IP_DIRS     = "./ip ../vhdl/ip"

vivado = vivado -nojournal -nolog -notrace -mode batch -source ./scripts/$1 $2

##==============================================================================
##Makefile Help for Vivado project.
##==============================================================================
##
##Parameters
##----------
##Targets: project, upgrade_ips, bitstream, sdk
##  GUI=<0 or 1> (default: 0)
##  e.g. `make project GUI=1`
##
##Supported Targets
##-----------------

all: project bitstream sdk ##	- Default target.
##
project: ##			- Create/Open Vivado project.
	@mkdir -p $(VIVADO_DIR)
	@$(call vivado,create_project.tcl,-tclargs $(VIVADO_DIR) $(IP_DIRS) $(GUI))

upgrade_ips: ##			- Upgrade changed IPs in the design.
	@echo "Upgrading IPs ..."
	@$(call vivado,upgrade_ips.tcl,-tclargs $(VIVADO_DIR) $(IP_DIRS) $(GUI))

bitstream: upgrade_ips ##		- Synthesize project and create a bitstream.
	@echo "Synthesize Vivado project ..."
	@mkdir -p $(VIVADO_DIR)
	@$(call vivado,synth.tcl,-tclargs $(VIVADO_DIR) $(GUI))

sdk: ##				- Create/Open SDK project.
	@echo "Creating SDK ..."
	@xsdk -batch -source ./scripts/create_sdk.tcl $(GUI)
ifeq ($(GUI),1)
	@xsdk -workspace ./sdk
endif

##
clean-sdk: ##			- Clean all outputs of SDK.
	@echo "Cleaning SDK stuff..."
	git clean -xdf sdk/

clean-vivado: ##			- Clean all outputs of Vivado project.
	@echo "Cleaning SDK stuff..."
	git clean -xdf generated/

clean-all: ##			- Clean all outputs.
	@echo "Cleaning..."
	git clean -xdf

help: ##				- Show this help message.
	@grep -h "##" Makefile | grep -v "\"##\"" | sed -e 's/##//g'

.PHONY: all project upgrade_ips bitstream sdk clean-sdk clean-vivado clean-all help

##
##==============================================================================
##*** NOTE: Makefile requires following setup:
##
##      - Vivado (vivado) can be found in PATH.
##      - Vivado SDK (xsdk) can be found in PATH.
##
##==============================================================================
