#-------------------------------------------------------------------------------
# File        : hls_csynth.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Run C Synthesis for Vivado HLS project.
#-------------------------------------------------------------------------------

set project_name [lindex $argv 2]

open_project $project_name
open_solution "solution1"

puts "###############################################################"
puts " Running csynth"
puts "###############################################################"

csynth_design

exit
