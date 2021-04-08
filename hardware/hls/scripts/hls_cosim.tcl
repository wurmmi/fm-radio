#-------------------------------------------------------------------------------
# File        : hls_cosim.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Co-Simulate Vivado HLS project.
#-------------------------------------------------------------------------------

set project_name [lindex $argv 2]

open_project $project_name
open_solution "solution1"

puts "###############################################################"
puts " Running cosim_design"
puts "###############################################################"

cosim_design

exit
