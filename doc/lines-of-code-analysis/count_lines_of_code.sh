#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# File        : count_lines_of_code.sh
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Count lines of code in this repository and produce some statistics.
#-------------------------------------------------------------------------------

SCRIPT_PATH=$(dirname $(readlink -f $0))
cd $SCRIPT_PATH/../..

###
# Analysis done with CLOC (version 1.82)
# For more information on how to use CLOC, please visit:
#   https://github.com/AlDanial/cloc
###

#-------------------------------------------------------------------------------
# Matlab system design
#-------------------------------------------------------------------------------

cloc sim/matlab/                                 \
        --by-file-by-lang                        \
        --exclude-dir="auto-arrange-figs"        \
        --exclude-ext="mat"                      \
        --not-match-f="RBDSExample.m"            \
            | tee $SCRIPT_PATH/matlab_system_design.txt

#-------------------------------------------------------------------------------
# IP design
#-------------------------------------------------------------------------------

# VHDL IP
cloc hardware/vhdl/                                           \
        --by-file-by-lang                                     \
        --match-d='(rtl|utils)'                               \
        --not-match-f='(fixed_|fm_radio_axi|filter_(.*)_pkg)' \
            | tee $SCRIPT_PATH/ip_design_vhdl.txt

# HLS IP
cloc hardware/hls/src/ \
        --by-file-by-lang \
        --not-match-f='(filter_(.*).h)' \
            | tee $SCRIPT_PATH/ip_design_hls.txt
exit 0
#-------------------------------------------------------------------------------
# IP testbench
#-------------------------------------------------------------------------------

# Common

# VHDL testbench
cloc hardware/vhdl/ip/tb/ \
        --by-file \
        --not-match-f="fixed_"       \
            | tee $SCRIPT_PATH/ip_testbench_vhdl.txt

# HLS testbench
cloc hardware/hls/tb/ \
        --by-file-by-lang \
            | tee $SCRIPT_PATH/ip_testbench_hls.txt


#-------------------------------------------------------------------------------
# Vivado
#-------------------------------------------------------------------------------
