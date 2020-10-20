#!/usr/bin/env bash
################################################################################
# File        : stream-live-rtl2832u.sh
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Streams a FM radio station from RTL2832u.
################################################################################

rtl_fm -f 88.8e6 -s 200000 -r 48000 | aplay -r 48000 -f S16_LE
