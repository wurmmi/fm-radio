#-------------------------------------------------------------------------------
# file:      Makefile
# author:    Michael Wurm <wurm.michael95@gmail.com>
# copyright: 2021 Michael Wurm
# brief:     Makefile for Vivado project.
#-------------------------------------------------------------------------------

GUI = 0

SHELL        = /bin/bash
MAKEFILE_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

VIVADO_HLS_PROJECT_NAME = prj
ENV_SETUP_SCRIPT        = ../../vhdl/tb/setup_env.sh

GENERAL_OUT_DIR = ../generated
PROJ_DIR        = $(GENERAL_OUT_DIR)/fm_receiver_hls
IP_DIR          = $(GENERAL_OUT_DIR)/ip
VIVADO_DIR      = $(GENERAL_OUT_DIR)/vivado

IP_TOP         = fm_receiver
IP_PACKAGE     = $(PROJ_DIR)/**/**/impl/ip/*.zip
IP_DESTINATION = $(IP_DIR)/$(IP_TOP)

vivado = vivado -nojournal -nolog -notrace -mode batch -source ./scripts/$1.tcl $2

##==============================================================================
##Makefile Help for Vivado project.
##==============================================================================
##
##Supported Targets
##-----------------

all: create_project ##	- Default target.

project: ##				- Create Vivado project.
	@echo "Creating Vivado project ..."
	@$(call vivado,build,-tclargs 0 $(VIVADO_DIR) $(GUI))

##
clean: ##						- Clean outputs.
	@echo "Cleaning..."
	git clean -xdf ..

help: ##						- Show this help message.
	@grep -h "##" Makefile | grep -v "\"##\"" | sed -e 's/##//g'

.PHONY: create_project csim csim_analyze csim_reload_plots csynth ip_export clean help

##
##==============================================================================
##*** NOTE: Makefile requires following setup:
##
##      - Vivado HLS (vivado_hls) can be found in PATH.
##
##==============================================================================
