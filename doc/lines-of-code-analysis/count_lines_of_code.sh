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
#  Analysis is done with CLOC.
#  For more information on how to use CLOC, please visit: https://github.com/AlDanial/cloc
#
#  Choose a cloc version with the CLOC_CMD.
#    (1) need to 'sudo apt install cloc' (version 1.82 on Ubuntu 20.04)
#    (2) need to have Docker installed on your system - always uses latest available version
###
#CLOC_CMD="cloc"
CLOC_CMD="docker run --rm -v $REPO_ROOT:/tmp/ aldanial/cloc:latest"

cd $REPO_ROOT

#------------------------------------------------------------------------------      -
# Matlab system design
#-------------------------------------------------------------------------------

$CLOC_CMD sim/matlab/                                 \
        --by-file-by-lang                        \
        --exclude-dir="auto-arrange-figs"        \
        --exclude-ext="mat"                      \
        --not-match-f="RBDSExample.m"            \
        --ignored=/tmp/doc/lines-of-code-analysis/matlab_system_design_ignored.txt        \
            | tee $SCRIPT_PATH/matlab_system_design.txt

#-------------------------------------------------------------------------------
# IP design
#-------------------------------------------------------------------------------

# VHDL IP
$CLOC_CMD hardware/vhdl/                         \
        --by-file-by-lang                        \
        --match-d='(rtl|utils)'                  \
        --not-match-f='(fixed_|fm_radio_axi|filter_(.*)_pkg)' \
        --ignored=/tmp/doc/lines-of-code-analysis/ip_design_vhdl_ignored.txt        \
            | tee $SCRIPT_PATH/ip_design_vhdl.txt

# HLS IP
$CLOC_CMD hardware/hls/src/                      \
        --by-file-by-lang                        \
        --not-match-f='(filter_(.*).h)'          \
        --ignored=/tmp/doc/lines-of-code-analysis/ip_design_hls_ignored.txt        \
            | tee $SCRIPT_PATH/ip_design_hls.txt

#-------------------------------------------------------------------------------
# IP testbench
#-------------------------------------------------------------------------------

# Common
$CLOC_CMD hardware/common/                       \
        --by-file-by-lang                        \
        --exclude-dir="fixed_point"              \
        --ignored=/tmp/doc/lines-of-code-analysis/common_ignored.txt \
            | tee $SCRIPT_PATH/common.txt

# VHDL testbench
$CLOC_CMD hardware/vhdl/ip/tb/                   \
        --by-file-by-lang                        \
        --ignored=/tmp/doc/lines-of-code-analysis/ip_testbench_vhdl_ignored.txt \
            | tee $SCRIPT_PATH/ip_testbench_vhdl.txt

# HLS testbench
$CLOC_CMD hardware/hls/                          \
        --by-file-by-lang                        \
        --match-d='(tb|scripts)'                 \
        --ignored=/tmp/doc/lines-of-code-analysis/ip_testbench_hls_ignored.txt \
        --not-match-f='(export|synth)'           \
            | tee $SCRIPT_PATH/ip_testbench_hls.txt

#-------------------------------------------------------------------------------
# Vivado
#-------------------------------------------------------------------------------

# SDK firmware
$CLOC_CMD hardware/vivado/                       \
        --by-file-by-lang                        \
        --match-d='(sdk|scripts)'                \
        --not-match-f='(upgrade_ips|wav_to_txt|synth|create_project)'              \
        --ignored=/tmp/doc/lines-of-code-analysis/vivado_sdk_firmware_ignored.txt \
            | tee $SCRIPT_PATH/vivado_sdk_firmware.txt

# Scripts
