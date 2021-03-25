#-------------------------------------------------------------------------------
# File        : create_project.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Create Vivado project.
#-------------------------------------------------------------------------------

set build_dir [lindex $argv 0]
cd build_dir

source ../bd/fm_receiver_project.tcl

exit
