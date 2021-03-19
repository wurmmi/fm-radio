#-------------------------------------------------------------------------------
# File        : hls_sim.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Simulate Vivado HLS project.
#-------------------------------------------------------------------------------

set project_name [lindex $argv 2]

open_project $project_name
open_solution "solution1"

csim_design -clean

exit
