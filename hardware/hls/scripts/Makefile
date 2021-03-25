#-------------------------------------------------------------------------------
# file:      Makefile
# author:    Michael Wurm <wurm.michael95@gmail.com>
# copyright: 2021 Michael Wurm
# brief:     Makefile for FM Receiver IP.
#-------------------------------------------------------------------------------

GUI = 0
SHELL := /bin/bash

MAKEFILE_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

VIVADO_HLS_PROJECT_NAME = prj
ENV_SETUP_SCRIPT = ../../vhdl/tb/setup_env.sh

GENERAL_OUT_DIR=../generated
PROJ_DIR=$(GENERAL_OUT_DIR)/fm_receiver

PYTHON_RELOAD_PLOTS_CODE = """from helpers import reload_all_plots_pickle; \
               					 			reload_all_plots_pickle('../tb/output')\
            							 """

##--------------------------------------------------------------------
##Makefile Help for FM Receiver.
##--------------------------------------------------------------------
##
##Supported Targets
##-----------------

all: hls_create_project hls_csim ##	- Default target.

hls_create_project: ##			- Create HLS project.
	@mkdir -p $(PROJ_DIR)
	@cd $(PROJ_DIR) && vivado_hls -f $(MAKEFILE_DIR)/create_hls_project.tcl $(VIVADO_HLS_PROJECT_NAME)
	@echo Done.

hls_csim: ##				- Run C simulation.
ifeq ($(GUI),1)
	@cd $(PROJ_DIR) && vivado_hls -p $(VIVADO_HLS_PROJECT_NAME)
	@echo Done.
else
	@cd $(PROJ_DIR) && vivado_hls -f $(MAKEFILE_DIR)/hls_sim.tcl $(VIVADO_HLS_PROJECT_NAME)
	@source $(ENV_SETUP_SCRIPT) && python ../tb/analyze_tb_results.py
endif

hls_csim_analyze: ##	- Run analysis for latest csim.
	@source $(ENV_SETUP_SCRIPT) && python ../tb/analyze_tb_results.py

hls_csim_reload_plots: ##			- Reload plots from latest csim.
	@source $(ENV_SETUP_SCRIPT) && python -c $(PYTHON_RELOAD_PLOTS_CODE)

hls_csynth: ## 				- Run C synthesis.
	@cd $(PROJ_DIR) && vivado_hls -f $(MAKEFILE_DIR)/hls_csynth.tcl $(VIVADO_HLS_PROJECT_NAME)

##
clean: ##					- Clean outputs.
	@echo "Cleaning..."
	git clean -x -d -f

help: ##					- Show this help message.
	@grep -h "##" Makefile | grep -v "\"##\"" | sed -e 's/##//g'

.PHONY: hls_create_project hls_csim hls_csim_analyze hls_csim_reload_plots hls_csynth clean help

##
##--------------------------------------------------------------------
##*** NOTE: Makefile requires following setup:
##
##      - Vivado HLS (vivado_hls) can be found in PATH.
##
##--------------------------------------------------------------------
