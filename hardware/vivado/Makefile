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
IP_DIRS     = "./ip ../vhdl"

vivado = vivado -nojournal -nolog -notrace -mode batch -source ./scripts/$1 $2

##==============================================================================
##Makefile Help for Vivado project.
##==============================================================================
##
##Supported Targets
##-----------------

all: project synth sdk ##		- Default target.

project: ##			- Create/Open Vivado project.
	@mkdir -p $(VIVADO_DIR)
	@$(call vivado,create_project.tcl,-tclargs $(VIVADO_DIR) $(IP_DIRS) $(GUI))

synth: ##				- Synthesize Vivado project.
	@echo "Synthesize Vivado project ..."
	@mkdir -p $(VIVADO_DIR)
	@$(call vivado,synth.tcl,-tclargs $(VIVADO_DIR) $(GUI))

sdk: ##				- Create/Open SDK project.
	@echo "Creating SDK ..."
	@xsdk -batch -source ./scripts/create_sdk.tcl
ifeq ($(GUI),1)
	@xsdk -workspace ./sdk
endif

##
clean-sdk: ##			- Clean all outputs of SDK.
	@echo "Cleaning SDK stuff..."
	git clean -xdf sdk/

clean-all: ##			- Clean all outputs.
	@echo "Cleaning..."
	git clean -xdf

help: ##				- Show this help message.
	@grep -h "##" Makefile | grep -v "\"##\"" | sed -e 's/##//g'

.PHONY: project synth sdk clean-all help

##
##==============================================================================
##*** NOTE: Makefile requires following setup:
##
##      - Vivado HLS (vivado) can be found in PATH.
##
##==============================================================================
