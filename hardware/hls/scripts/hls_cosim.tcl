#-------------------------------------------------------------------------------
# File        : hls_cosim.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Co-Simulate Vivado HLS project.
#-------------------------------------------------------------------------------

set project_name [lindex $argv 2]

open_project $project_name
open_solution "solution1"

source ../../scripts/hls_defines.tcl

puts "###############################################################"
puts " Running cosim_design"
puts "###############################################################"

# This is a workaround (Xilinx defines __RTL_SIMULATION__ only for SystemC testbenches).
# https://github.com/fastmachinelearning/hls4ml/issues/147#issuecomment-508148683
add_files -tb $TB_DIR/main.cpp -cflags "$CPPFLAGS -D__RTL_SIMULATION__"

cosim_design -wave_debug -trace_level all -rtl vhdl -tool xsim

exit
