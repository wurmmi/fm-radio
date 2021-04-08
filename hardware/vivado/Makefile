#-------------------------------------------------------------------------------
# file:      Makefile
# author:    Michael Wurm <wurm.michael95@gmail.com>
# copyright: 2021 Michael Wurm
# brief:     Makefile for Vivado project.
#-------------------------------------------------------------------------------

GUI = 0

SHELL        = /bin/bash
MAKEFILE_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

GENERAL_OUT_DIR = ./generated
VIVADO_DIR      = $(GENERAL_OUT_DIR)/vivado
IP_DIR          = ../hls/generated/ip

vivado = vivado -nojournal -nolog -notrace -mode batch -source ./scripts/$1 $2

##==============================================================================
##Makefile Help for Vivado project.
##==============================================================================
##
##Supported Targets
##-----------------

all: create_project ##		- Default target.

create_project: ##		- Create Vivado project.
	@echo "Creating Vivado project ..."
	@mkdir -p $(VIVADO_DIR)
	@$(call vivado,create_project.tcl,-tclargs $(VIVADO_DIR) $(IP_DIR) $(GUI))

synth: ##		- Synthesize Vivado project.
	@echo "Synthesize Vivado project ..."
	@mkdir -p $(VIVADO_DIR)
	@$(call vivado,synth.tcl,-tclargs $(VIVADO_DIR) $(IP_DIR) $(GUI))

##
clean: ##				- Clean outputs.
	@echo "Cleaning..."
	git clean -xdf ..

help: ##				- Show this help message.
	@grep -h "##" Makefile | grep -v "\"##\"" | sed -e 's/##//g'

.PHONY: create_project clean help

##
##==============================================================================
##*** NOTE: Makefile requires following setup:
##
##      - Vivado HLS (vivado) can be found in PATH.
##
##==============================================================================
