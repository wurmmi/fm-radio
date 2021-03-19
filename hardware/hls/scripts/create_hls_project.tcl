#-------------------------------------------------------------------------------
# File        : create_hls_project.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Create Vivado HLS project.
#-------------------------------------------------------------------------------

set SRC_DIR  "../../src"
set TB_DIR   "../../tb"
set CPPFLAGS "--std=c++11 -I$SRC_DIR"

set project_name [lindex $argv 2]

open_project -reset $project_name
set_top fm_receiver

add_files      $SRC_DIR/utils/fir.cpp       -cflags $CPPFLAGS
add_files      $SRC_DIR/utils/fir.hpp
add_files      $SRC_DIR/fm_global.hpp
add_files      $SRC_DIR/fm_receiver.cpp     -cflags $CPPFLAGS
add_files      $SRC_DIR/fm_receiver.hpp
add_files -tb  $TB_DIR/main.cpp             -cflags $CPPFLAGS
add_files -tb  $TB_DIR/main.hpp
add_files -tb  $TB_DIR/helper/tb_helper.hpp
add_files -tb  $TB_DIR/data/

open_solution -reset "solution1"

set_part {xc7z020clg484-1}
create_clock -period 10 -name default

config_rtl -reset control -reset_level low

exit
