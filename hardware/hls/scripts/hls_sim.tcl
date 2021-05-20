#-------------------------------------------------------------------------------
# File        : hls_sim.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Simulate Vivado HLS project.
#-------------------------------------------------------------------------------

set project_name [lindex $argv 2]

open_project $project_name
open_solution "solution1"

source ../../scripts/hls_defines.tcl

puts "###############################################################"
puts " Running csim"
puts "###############################################################"

# Revert the workaround, described in "hls_cosim.tcl"
add_files -tb $TB_DIR/main.cpp -cflags $CPPFLAGS

csim_design -clean -ldflags {-fsanitize=undefined}

exit
