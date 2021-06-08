#-------------------------------------------------------------------------------
# File        : upgrade_ips.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Upgrade IPs in the Vivado project.
#-------------------------------------------------------------------------------

set build_dir [lindex $argv 0]
set ip_dirs   [lindex $argv 1]
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

  puts "- Opening block design"
  open_bd_design [get_files $proj_name.bd]

  puts "- Update IP catalog"
  update_ip_catalog -rebuild -scan_changes

  puts "- Upgrade IP"
  upgrade_ip [get_ips]
  #upgrade_ip -vlnv MWURM:hls:fm_receiver_hls:0.1 [get_ips  proj_fm_receiver_hls_0_0] -log ip_upgrade.log

  puts "- Validate design"
  validate_bd_design

  puts "- Save and export block design"
  save_bd_design
  write_bd_tcl -force ./bd/$proj_name.tcl

  exitif 0
} else {
  puts "Project does not exist yet!"
  exitif 1
}
