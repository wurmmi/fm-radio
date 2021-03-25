#-------------------------------------------------------------------------------
# file:      Makefile
# author:    Michael Wurm <wurm.michael95@gmail.com>
# copyright: 2021 Michael Wurm
# brief:     Makefile for FM Receiver IP.
#-------------------------------------------------------------------------------

GUI = 0

SHELL        = /bin/bash
MAKEFILE_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

VIVADO_HLS_PROJECT_NAME = prj
ENV_SETUP_SCRIPT        = ../../vhdl/tb/setup_env.sh

GENERAL_OUT_DIR = ../generated
PROJ_DIR        = $(GENERAL_OUT_DIR)/fm_receiver
IP_DIR          = $(GENERAL_OUT_DIR)/ip

IP_TOP         = fm_receiver
IP_PACKAGE     = $(PROJ_DIR)/**/**/impl/ip/*.zip
IP_DESTINATION = $(IP_DIR)/$(IP_TOP)

PYTHON_RELOAD_PLOTS_CODE = """from helpers import reload_all_plots_pickle; \
               					 			reload_all_plots_pickle('../tb/output') \
            							 """

vivado_hls_batch = \
	@cd $(PROJ_DIR) && vivado_hls -f $(MAKEFILE_DIR)/$1 $2 $3

##==============================================================================
##Makefile Help for FM Receiver.
##==============================================================================
##
##Supported Targets
##-----------------

all: create_project csim csynth ##	- Default target.

create_project: ##				- Create HLS project.
	@mkdir -p $(PROJ_DIR)
	@$(call vivado_hls_batch,create_hls_project.tcl,$(VIVADO_HLS_PROJECT_NAME))
	@echo Done.

csim: ##					- Run C simulation.
ifeq ($(GUI),1)
	@cd $(PROJ_DIR) && vivado_hls -p $(VIVADO_HLS_PROJECT_NAME)
	@echo Done.
else
	@$(call vivado_hls_batch,hls_sim.tcl,$(VIVADO_HLS_PROJECT_NAME))
	@source $(ENV_SETUP_SCRIPT) && python ../tb/analyze_tb_results.py
endif

csim_analyze: ##				- Run analysis for latest csim.
	@source $(ENV_SETUP_SCRIPT) && python ../tb/analyze_tb_results.py

csim_reload_plots: ##				- Reload plots from latest csim.
	@source $(ENV_SETUP_SCRIPT) && python -c $(PYTHON_RELOAD_PLOTS_CODE)

csynth: ## 					- Run C synthesis.
	@$(call vivado_hls_batch,hls_csynth.tcl,$(VIVADO_HLS_PROJECT_NAME))

ip_export: ##					- Export IP files (UNTESTED).
	@$(call vivado_hls_batch,ip_export.tcl,$(VIVADO_HLS_PROJECT_NAME) $(IP_TOP))
	@rm -rf $(IP_DESTINATION)/*
	@unzip -o $(IP_PACKAGE) -d $(IP_DESTINATION)
	# Add a custom IP Logo for the Block Design
	#cp ./src/img/logo.png $IP_DESTINATION/misc/logo.png

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
