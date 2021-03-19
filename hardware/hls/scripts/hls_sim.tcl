#-------------------------------------------------------------------------------
# File        : hls_sim.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Simulate Vivado HLS project.
#-------------------------------------------------------------------------------

open_project prj
open_solution "solution1"

csim_design -clean

exit
