############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
############################################################
open_project project
add_files src/utils/fir.cpp
add_files src/utils/fir.hpp
add_files src/fm_global.hpp
add_files src/fm_receiver.cpp
add_files src/fm_receiver.hpp
add_files -tb tb/main.cpp
add_files -tb tb/main.hpp
open_solution "solution1"
set_part {xa7a12tcsg325-1q}
create_clock -period 10 -name default
#source "./project/solution1/directives.tcl"
csim_design -clean
csynth_design
cosim_design
export_design -format ip_catalog
