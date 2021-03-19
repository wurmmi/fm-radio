#!/usr/bin/env bash
################################################################################
# File        : run.sh
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Abstraction of main actions on the Vivado project(s).
################################################################################

set -euo pipefail

ARG=${1:-"unset"}
GUI=${2:-"unset"}

SCRIPT_PATH=$(realpath $(dirname $BASH_SOURCE))
cd $SCRIPT_PATH

VIVADO_HLS_PROJECT_NAME="prj"
VIVADO_HLS_BATCH="vivado_hls -f"
VIVADO_HLS_GUI="vivado_hls -p"
VIVADO_HLS_GUI="vivado_hls -p"

GENERAL_OUT_DIR=$SCRIPT_PATH/../generated
PROJ_DIR=$GENERAL_OUT_DIR/fm_receiver
IP_DIR=$GENERAL_OUT_DIR/ip


mkdir -p $PROJ_DIR
mkdir -p $IP_DIR

cd $PROJ_DIR


if [ "$ARG" == "hls_project" ]; then
  $VIVADO_HLS_BATCH $SCRIPT_PATH/create_hls_project.tcl $VIVADO_HLS_PROJECT_NAME
  exit 0
elif [ "$ARG" == "hls_sim" ]; then
  $VIVADO_HLS_BATCH $SCRIPT_PATH/hls_sim.tcl $VIVADO_HLS_PROJECT_NAME
  exit 0
elif [ "$ARG" == "hls_gui" ]; then
  $VIVADO_HLS_GUI $VIVADO_HLS_PROJECT_NAME
  exit 0
elif [ "$ARG" == "hls_synth" ]; then
  $VIVADO_HLS_BATCH $SCRIPT_PATH/hls_synth.tcl
  exit 0
elif [ "$ARG" == "hls_export" ]; then
  $VIVADO_HLS_BATCH $SCRIPT_PATH/hls_export.tcl

  # Unpack the IP zip package
  IP_PACKAGE=$PROJ_DIR/**/**/impl/ip/*.zip
  IP_DESTINATION=$IP_DIR/cordic
  rm -rf $IP_DESTINATION/*
  unzip -o $IP_PACKAGE -d $IP_DESTINATION
  # Add a custom IP Logo for the Block Design
  #cp ./src/img/logo.png $IP_DESTINATION/misc/logo.png

  cd -
  exit 0
else
  echo "===================================================================================="
  echo "(ERROR) Wrong or invalid argument."
  echo "Usage: ./run.sh <hls_project|hls_sim|hls_synth|hls_export>"
  echo "===================================================================================="
  exit 1
fi
