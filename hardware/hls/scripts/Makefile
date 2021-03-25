#-------------------------------------------------------------------------------
# file:      Makefile
# author:    Michael Wurm <wurm.michael95@gmail.com>
# copyright: 2021 Michael Wurm
# brief:     Makefile for FM Receiver IP.
#-------------------------------------------------------------------------------

TOP = blinkylight
LOG = $(shell find ./build/log/*/*.wlf 2> /dev/null | tail -n 1)
GUI = 0

VIVADO_HLS_PROJECT_NAME = prj
ENV_SETUP_SCRIPT = ../../vhdl/tb/setup_env.sh


##--------------------------------------------------------------------
##Makefile Help for FM Receiver.
##--------------------------------------------------------------------
##
##Supported Targets
##-----------------

all: uvvm ip test wave ##				- Default target.

hls_create_project: ##				- Create HLS project.
	@vivado_hls -f ./create_hls_project.tcl $(VIVADO_HLS_PROJECT_NAME)
	@echo Done.

hls_csim: ##				- Run C simulation.
ifeq ($(GUI),1)
	@vivado_hls -p $(VIVADO_HLS_PROJECT_NAME)
	@source $(ENV_SETUP_SCRIPT)
  @python ../tb/analyze_tb_results.py
	@echo Done.
else
	@vivado_hls -f ./hls_sim.tcl $(VIVADO_HLS_PROJECT_NAME)
endif

hls_csim_reload_plots: ##				- Reload plots from latest csim.
	@source $(ENV_SETUP_SCRIPT)
	@python -c """from helpers import reload_all_plots_pickle; \
               reload_all_plots_pickle('../tb/output')\
            """
##
clean: ##				- Clean outputs.
	@echo "Cleaning..."
	git clean -x -d -f

help: ##				- Show this help message.
	@grep -h "##" Makefile | grep -v "\"##\"" | sed -e 's/##//g'

.PHONY: hls_create_project hls_csim hls_csim_reload_plots clean help

##
##--------------------------------------------------------------------
##*** NOTE: Makefile requires following setup:
##
##      - Vivado HLS (vivado_hls) can be found in PATH.
##
##--------------------------------------------------------------------
