#-------------------------------------------------------------------------------
# file:      Makefile
# author:    Michael Wurm <wurm.michael95@gmail.com>
# copyright: 2021 Michael Wurm
# brief:     Makefile for FM Receiver IP (HLS).
#-------------------------------------------------------------------------------

# TODO: move this file one directory higher (?)

# --- Defines ---
GUI = 0

SHELL        = /bin/bash
MAKEFILE_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

VIVADO_HLS_PROJECT_NAME = prj
ENV_SETUP_SCRIPT        = ../../vhdl/tb/setup_env.sh

PROJ_DIR = ../generated/fm_receiver_hls
IP_DIR   = ../../vivado/ip
WAVE_DIR = $(PROJ_DIR)/prj/solution1/sim/vhdl

IP_TOP         = fm_receiver_hls
IP_PACKAGE     = $(PROJ_DIR)/**/**/impl/ip/*.zip
IP_DESTINATION = $(IP_DIR)/$(IP_TOP)

PYTHON_RELOAD_PLOTS_CODE = """from helpers import reload_all_plots_pickle; \
               					 			reload_all_plots_pickle('../tb/output') \
            							 """

# --- Functions ---
vivado_hls_batch = \
	@cd $(PROJ_DIR) && vivado_hls -f $(MAKEFILE_DIR)/$1 $2 $3

analyze_tb_results = \
	source $(ENV_SETUP_SCRIPT) && python ../tb/analyze_tb_results.py

CLANG_FORMAT_FILES = $$(find ../ -type f -name "*.[ch]pp" -o -name "*.[ch]")
run_clang_format =                      \
	for file in $(CLANG_FORMAT_FILES); do \
		echo "Formatting $${file}";         \
		clang-format -i "$${file}";         \
	done                                  \

##==============================================================================
##Makefile Help for FM Receiver.
##==============================================================================
##
##Supported Targets
##-----------------

all: create_project csim csynth cosim ip_export ##	- Default target.
##
create_project: ##					- Create HLS project.
	@mkdir -p $(PROJ_DIR)
	@$(call vivado_hls_batch,create_hls_project.tcl,$(VIVADO_HLS_PROJECT_NAME))
	@echo Done.

gui: ##							- Open HLS project in GUI.
	@cd $(PROJ_DIR) && vivado_hls -p $(VIVADO_HLS_PROJECT_NAME)

csim: create_project ##					- Run C simulation.
	@rm -f ../tb/output/*
	@$(call vivado_hls_batch,hls_csim.tcl,$(VIVADO_HLS_PROJECT_NAME))
	@$(call analyze_tb_results)
	@echo Done.

csim_analyze: ##						- Run analysis for latest csim.
	@$(call analyze_tb_results)
	@echo Done.

reload_plots: ##						- Reload plots from latest csim/co-sim.
	@source $(ENV_SETUP_SCRIPT) && python -c $(PYTHON_RELOAD_PLOTS_CODE)

csynth: create_project ##					- Run C synthesis.
	@$(call vivado_hls_batch,hls_csynth.tcl,$(VIVADO_HLS_PROJECT_NAME))
	@echo Done.

cosim:  ##						- Run co-simulation.
	@$(call vivado_hls_batch,hls_cosim.tcl,$(VIVADO_HLS_PROJECT_NAME))
	@$(call analyze_tb_results)
	@echo Done.

cosim_open_wave: ##					- Open waveform of co-simulation.
	@echo "Opening waveform..."
	@cd $(WAVE_DIR) && vivado -source $(MAKEFILE_DIR)/hls_cosim_open_wave.tcl

ip_export: ##						- Export IP files.
	@$(call vivado_hls_batch,ip_export.tcl,$(VIVADO_HLS_PROJECT_NAME) $(IP_TOP))
	@rm -rf $(IP_DESTINATION)/*
	@mkdir -p $(IP_DESTINATION)
	@unzip -o $(IP_PACKAGE) -d $(IP_DESTINATION)
	cp ../doc/ip_logo.png $(IP_DESTINATION)/misc/logo.png
	@echo Done.

##
clang-format: ##						- Format all the C/C++ sources.
	@$(call run_clang_format)

##
clean: ##							- Clean outputs.
	@echo "Cleaning..."
	git clean -xdf ..
	@echo Done.

help: ##							- Show this help message.
	@grep -h "##" Makefile | grep -v "\"##\"" | sed -e 's/##//g'

.PHONY: all create_project gui csim csim_analyze reload_plots csynth \
				cosim cosim_open_wave ip_export clean help

##
##==============================================================================
##*** NOTE: Makefile requires following setup:
##
##      - Vivado HLS (vivado_hls) can be found in PATH.
##      - Vivado (vivado) can be found in PATH.
##
##==============================================================================
