#-------------------------------------------------------------------------------
# File        : hls_sim.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Simulate Vivado HLS project.
#-------------------------------------------------------------------------------

set project_name [lindex $argv 2]
set ip_name [lindex $argv 3]

open_project $project_name
open_solution "solution1"

puts "###############################################################"
puts " Running IP export"
puts "###############################################################"

export_design -format ip_catalog              \
              -vendor "MWURM"                 \
              -library "hls"                  \
              -ipname "$ip_name"              \
              -display_name "$ip_name"        \
              -version "0.1"                  \
              -description "FM Receiver HLS"

exit 0
