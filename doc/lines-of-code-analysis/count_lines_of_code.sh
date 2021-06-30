#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# File        : count_lines_of_code.sh
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Count lines of code in this repository and produce some statistics.
#-------------------------------------------------------------------------------

SCRIPT_PATH=$(dirname $(readlink -f $0))
REPO_ROOT=$SCRIPT_PATH/../../

# Clean previous output products
cd $SCRIPT_PATH
rm -f *.txt

###
# NOTE:
#  Analysis done with CLOC.
#  For more information on how to use CLOC, please visit: https://github.com/AlDanial/cloc
#
#  Choose a cloc version with the CLOC_CMD.
#  (1) need to 'sudo apt install cloc' (version 1.82 on Ubuntu 20.04)
#  (2) need to have docker installed on your system - always uses latest available version
###
#CLOC_CMD="cloc"
CLOC_CMD="docker run --rm -v $REPO_ROOT:/tmp aldanial/cloc:latest"

cd $REPO_ROOT

#------------------------------------------------------------------------------      -
# Matlab system design
#-------------------------------------------------------------------------------

$CLOC_CMD sim/matlab/                                 \
        --by-file-by-lang                        \
        --exclude-dir="auto-arrange-figs"        \
        --exclude-ext="mat"                      \
        --not-match-f="RBDSExample.m"            \
            | tee $SCRIPT_PATH/sim_matlab_system_design.txt

#-------------------------------------------------------------------------------
# IP design
#-------------------------------------------------------------------------------

# VHDL IP
$CLOC_CMD hardware/vhdl/                              \
        --by-file-by-lang                        \
        --match-d='(rtl|utils)'                  \
        --not-match-f='(fixed_|fm_radio_axi|filter_(.*)_pkg)' \
            | tee $SCRIPT_PATH/hw_ip_design_vhdl.txt

# HLS IP
$CLOC_CMD hardware/hls/src/                           \
        --by-file-by-lang                        \
        --not-match-f='(filter_(.*).h)'          \
            | tee $SCRIPT_PATH/hw_ip_design_hls.txt

#-------------------------------------------------------------------------------
# IP testbench
#-------------------------------------------------------------------------------

# Common
$CLOC_CMD hardware/common/                            \
        --by-file-by-lang                        \
        --exclude-dir="fixed_point"        \
            | tee $SCRIPT_PATH/hw_common.txt

exit 0

# VHDL testbench
$CLOC_CMD hardware/vhdl/ip/tb/ \
        --by-file \
        --not-match-f="fixed_"       \
            | tee $SCRIPT_PATH/ip_testbench_vhdl.txt

# HLS testbench
$CLOC_CMD hardware/hls/tb/ \
        --by-file-by-lang \
            | tee $SCRIPT_PATH/ip_testbench_hls.txt


#-------------------------------------------------------------------------------
# Vivado
#-------------------------------------------------------------------------------
