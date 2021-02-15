#!/usr/bin/env bash
################################################################################
# File        : record-rtl2832u.sh
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Records IQ data from RTL2832u to file.
################################################################################

# Record 10s of IQ signal data.
# NOTE:
#   Saalfelden: OE3 98.1 MHz

center_freq=98.0e6
sample_freq=1000000
n_seconds=10
out_file="./recordings/fm_record.bin"

n_samples=$(( $sample_freq * $n_seconds))
echo "Recording $n_samples @ $sample_freq SPS ($n_seconds seconds)."

cmd="rtl_sdr -f $center_freq -s $sample_freq -n $n_samples $out_file"

echo "Using this command:"
echo -e "$cmd \n"

eval $cmd
