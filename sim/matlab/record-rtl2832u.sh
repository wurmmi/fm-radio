#!/usr/bin/env bash
################################################################################
# File        : record-rtl2832u.sh
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Records IQ data from RTL2832u to file.
################################################################################

rtl_sdr -f 93.3e6 -s 1e6 -n 5e6 fm_record.bin
