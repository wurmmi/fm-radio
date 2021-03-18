################################################################################
# File        : create_hls_project.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Create Vivado HLS project.
################################################################################

set SRC_DIR  "../src"
set CPPFLAGS "--std=c++11 -I$SRC_DIR"

open_project -reset prj
add_files       $SRC_DIR/utils/fir.hpp
add_files       $SRC_DIR/utils/fir.cpp     -cflags $CPPFLAGS
add_files -tb   $SRC_DIR/../tb/main.hpp
add_files -tb   $SRC_DIR/../tb/main.cpp    -cflags $CPPFLAGS

open_solution -reset solution

set_top fm_receiver
create_clock -period 20 -name default
# TODO: is it possible to set the MiniZed board directly?
set_part "xc7z007sclg225-1"

config_rtl -reset control -reset_level low

quit
