#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# File        : count_lines_of_code.sh
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Count lines of code in this repository and produce some statistics.
#-------------------------------------------------------------------------------

SCRIPT_PATH=$(dirname $(readlink -f $0))
REPO_ROOT=$SCRIPT_PATH/../../

cd $REPO_ROOT

###
# NOTE:
#  Analysis is done with CLOC.
#  For more information on how to use CLOC, please visit: https://github.com/AlDanial/cloc
#
#  Choose a cloc version with the CLOC_CMD.
#    (1) need to `sudo apt install cloc` (version 1.82 on Ubuntu 20.04)
#    (2) need to have Docker installed on your system - always uses latest available version
###
#CLOC_CMD="cloc"
CLOC_CMD="docker run --rm -v $REPO_ROOT:/tmp/ aldanial/cloc:latest"

# Clean previous output products
SCRIPT_PATH_RELATIVE=doc/lines-of-code-analysis/output
mkdir -p $SCRIPT_PATH_RELATIVE
rm -f $SCRIPT_PATH_RELATIVE/*.txt

#-------------------------------------------------------------------------------

create_report () {
    $SCRIPT_PATH/get_total_columns.sh $OPTIONS | tee $FILE.txt
    echo -e "\n\n--- Detailed output ---\n" | tee -a $FILE.txt
    $CLOC_CMD $OPTIONS | tee -a $FILE.txt
}

#-------------------------------------------------------------------------------
# Matlab system design
#-------------------------------------------------------------------------------

echo "### Matlab system design"
FILE=$SCRIPT_PATH_RELATIVE/matlab_system_design
OPTIONS="sim/matlab/                             \
        --by-file-by-lang                        \
        --exclude-dir=auto-arrange-figs          \
        --exclude-ext=mat                        \
        --not-match-f=RBDSExample.m              \
        --ignored=/tmp/${FILE}_ignored.txt"

create_report;

#-------------------------------------------------------------------------------
# IP design
#-------------------------------------------------------------------------------

# VHDL IP
echo "### IP design VHDL"
FILE=$SCRIPT_PATH_RELATIVE/ip_design_vhdl
OPTIONS="hardware/vhdl/                          \
        --by-file-by-lang                        \
        --match-d=(rtl|utils)                    \
        --not-match-f=(fixed_|fm_radio_axi|filter_(.*)_pkg) \
        --ignored=/tmp/${FILE}_ignored.txt"

create_report;

# HLS IP
echo "### IP design HLS"
FILE=$SCRIPT_PATH_RELATIVE/ip_design_hls
OPTIONS="hardware/hls/src/                       \
        --by-file-by-lang                        \
        --not-match-f=(filter_(.*).h)            \
        --ignored=/tmp/${FILE}_ignored.txt"

create_report;

#-------------------------------------------------------------------------------
# IP testbench
#-------------------------------------------------------------------------------

# Common
echo "### IP testbench common"
FILE=$SCRIPT_PATH_RELATIVE/ip_testbench_common
OPTIONS="hardware/common/                        \
        --by-file-by-lang                        \
        --exclude-dir=fixed_point                \
        --ignored=/tmp/${FILE}_ignored.txt"

create_report;

# VHDL testbench
echo "### IP testbench VHDL"
FILE=$SCRIPT_PATH_RELATIVE/ip_testbench_vhdl
OPTIONS="hardware/vhdl/ip/tb/                    \
        --by-file-by-lang                        \
        --ignored=/tmp/${FILE}_ignored.txt"

create_report;

# HLS testbench
echo "### IP testbench HLS"
FILE=$SCRIPT_PATH_RELATIVE/ip_testbench_hls
OPTIONS="hardware/hls/                           \
        --by-file-by-lang                        \
        --match-d=(tb|scripts)                   \
        --not-match-f=(export|synth)             \
        --ignored=/tmp/${FILE}_ignored.txt"

create_report;

#-------------------------------------------------------------------------------
# Vivado
#-------------------------------------------------------------------------------

# SDK firmware
echo "### Vivado SDK firmware"
FILE=$SCRIPT_PATH_RELATIVE/vivado_sdk_firmware
OPTIONS="hardware/vivado/                        \
        --by-file-by-lang                        \
        --match-d=(sdk|scripts)                  \
        --not-match-f=(upgrade_ips|wav_to_txt|synth|create_project) \
        --ignored=/tmp/${FILE}_ignored.txt"

create_report;

# Scripts
echo "### Vivado scripts"
FILE=$SCRIPT_PATH_RELATIVE/vivado_scripts
OPTIONS="hardware/vivado/                        \
        --by-file-by-lang                        \
        --exclude-dir=bd,dc,doc,ip,sdk           \
        --ignored=/tmp/${FILE}_ignored.txt"

create_report;
