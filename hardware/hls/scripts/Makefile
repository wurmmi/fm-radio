#-------------------------------------------------------------------------------
# file:      Makefile
# author:    Michael Wurm <wurm.michael95@gmail.com>
# copyright: 2021 Michael Wurm
# brief:     Makefile for FM Receiver IP.
#-------------------------------------------------------------------------------

# TODO: move this file one directory higher (?)

GUI = 0

SHELL        = /bin/bash
MAKEFILE_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

VIVADO_HLS_PROJECT_NAME = prj
ENV_SETUP_SCRIPT        = ../../vhdl/tb/setup_env.sh

GENERAL_OUT_DIR = ../generated
PROJ_DIR        = $(GENERAL_OUT_DIR)/fm_receiver_hls
IP_DIR          = $(GENERAL_OUT_DIR)/ip
WAVE_DIR        = $(PROJ_DIR)/prj/solution1/sim/vhdl

IP_TOP         = fm_receiver
IP_PACKAGE     = $(PROJ_DIR)/**/**/impl/ip/*.zip
IP_DESTINATION = $(IP_DIR)/$(IP_TOP)

PYTHON_RELOAD_PLOTS_CODE = """from helpers import reload_all_plots_pickle; \
               					 			reload_all_plots_pickle('../tb/output') \
            							 """

vivado_hls_batch = \
	@cd $(PROJ_DIR) && vivado_hls -f $(MAKEFILE_DIR)/$1 $2 $3

analyze_tb_results = \
	source $(ENV_SETUP_SCRIPT) && python ../tb/analyze_tb_results.py

##==============================================================================
##Makefile Help for FM Receiver.
##==============================================================================
##
##Supported Targets
##-----------------

all: create_project csim csynth cosim ##	- Default target.
##
create_project: ##			- Create HLS project.
	@mkdir -p $(PROJ_DIR)
	@$(call vivado_hls_batch,create_hls_project.tcl,$(VIVADO_HLS_PROJECT_NAME))
	@echo Done.

gui: ##					- Open HLS project in GUI.
	@cd $(PROJ_DIR) && vivado_hls -p $(VIVADO_HLS_PROJECT_NAME)

csim: ##					- Run C simulation.
	@rm -f ../tb/output/*
	@$(call vivado_hls_batch,hls_sim.tcl,$(VIVADO_HLS_PROJECT_NAME))
	@$(call analyze_tb_results)
	@echo Done.

csim_analyze: ##				- Run analysis for latest csim.
	@$(call analyze_tb_results)
	@echo Done.

csim_reload_plots: ##			- Reload plots from latest csim.
	@source $(ENV_SETUP_SCRIPT) && python -c $(PYTHON_RELOAD_PLOTS_CODE)

csynth: ## 				- Run C synthesis.
	@$(call vivado_hls_batch,hls_csynth.tcl,$(VIVADO_HLS_PROJECT_NAME))
	@echo Done.

cosim: ## 				- Run co-simulation.
	@$(call vivado_hls_batch,hls_cosim.tcl,$(VIVADO_HLS_PROJECT_NAME))
	@$(call analyze_tb_results)
	@echo Done.

cosim_open_wave: ##			- Open waveform of co-simulation.
	@echo "Opening waveform..."
	@cd $(WAVE_DIR) && vivado -source $(MAKEFILE_DIR)/hls_cosim_open_wave.tcl

ip_export: ##				- Export IP files.
	@$(call vivado_hls_batch,ip_export.tcl,$(VIVADO_HLS_PROJECT_NAME) $(IP_TOP))
	@rm -rf $(IP_DESTINATION)/*
	@mkdir -p $(IP_DESTINATION)
	@unzip -o $(IP_PACKAGE) -d $(IP_DESTINATION)
	cp ../doc/ip_logo.png $(IP_DESTINATION)/misc/logo.png
	@echo Done.

##
clean: ##					- Clean outputs.
	@echo "Cleaning..."
	git clean -xdf ..
	@echo Done.

help: ##					- Show this help message.
	@grep -h "##" Makefile | grep -v "\"##\"" | sed -e 's/##//g'

.PHONY: all create_project gui csim csim_analyze csim_reload_plots csynth \
				cosim cosim_open_wave ip_export clean help

##
##==============================================================================
##*** NOTE: Makefile requires following setup:
##
##      - Vivado HLS (vivado_hls) can be found in PATH.
##      - Vivado (vivado) can be found in PATH.
##
##==============================================================================
