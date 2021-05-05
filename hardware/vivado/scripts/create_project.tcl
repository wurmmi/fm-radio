#-------------------------------------------------------------------------------
# File        : create_project.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Create Vivado project.
#-------------------------------------------------------------------------------

set build_dir [lindex $argv 0]
set ip_dirs    [lindex $argv 1]
set open_gui  [lindex $argv 2]

set proj_name "proj"
set device xc7z020clg484-1

proc exitif {code} {
  global open_gui
  if {$open_gui == 0} {
    exit $code
  }
}

if {$open_gui == 1} {
  start_gui
}

if {[file exists $build_dir/$proj_name.xpr]} {
  puts "--- - Opening existing project"
  open_project $build_dir/$proj_name.xpr
} elseif {[catch {
  puts "--- - Creating new project"
  create_project $proj_name $build_dir -part $device -force

  set_property target_language VHDL [current_project]

  set_property ip_repo_paths {$ip_dirs} [current_project]
  update_ip_catalog

  set_property BOARD_PART em.avnet.com:zed:part0:1.4 [current_project]

  add_files -fileset constrs_1 -norecurse "./dc/zedboard.xdc"

  puts "--- - Creating block design"
  source ./bd/$proj_name.tcl

  # Generate the wrapper
  set design_name [get_bd_designs]
  make_wrapper -files [get_files $design_name.bd] -top -import

  regenerate_bd_layout
  puts "### Block design created."
} ]} {
  puts "ERROR: Project creation failed."
  exitif 1
}
