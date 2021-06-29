#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# File        : count_lines_of_code.sh
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Count lines of code in this repository and produce a statistic.
#-------------------------------------------------------------------------------

SCRIPT_PATH=$(dirname $(readlink -f $0))
cd $SCRIPT_PATH/../..
echo "SCRIPT_PATH: $SCRIPT_PATH"

# VHDL IP
cloc hardware/vhdl/ip/rtl/ --by-file --not-match-f="fixed_" | tee $SCRIPT_PATH/VHDL_IP.txt

# HLS IP
cloc hardware/hls/ --by-file --not-match-f="fixed_" | tee $SCRIPT_PATH/HLS_IP.txt
