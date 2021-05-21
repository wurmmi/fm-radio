################################################################################
# File        : create_sdk.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Set up an SDK project.
#               Creates Hardware Platform, Board Support Package and
#               imports the application project, with additional sources.
################################################################################

set origin_dir [file dirname [info script]]
set workspace_dir [file normalize "${origin_dir}/../sdk"]

set design_name "fm_radio"

set hw_name ${design_name}_wrapper_hw_platform_0
set bsp_name standalone_bsp_0
set app_name standalone_bsp_0_Passthrough_A53_1

puts "(VideoSigXilinx) Opening SDK..."

setws $workspace_dir
cd $workspace_dir
puts "(VideoSigXilinx) Set workspace to '[getws]'."

puts "(VideoSigXilinx) Creating HW platform..."
if {![file exists "$hw_name"]} {
  createhw -name $hw_name -hwspec latest_bin/${design_name}_wrapper.hdf

  # Create driver files
  # NOTE: This is not documented in the XSCT UG1208
  getperipherals $hw_name/system.hdf
}
# Replace the auto-generated bitfile with the 'real' one.
file copy -force latest_bin/${design_name}_wrapper.bit $hw_name

puts "(VideoSigXilinx) Creating BSP..."
if {![file exists "$bsp_name"]} {
  createbsp -name $bsp_name -hwproject $hw_name -proc psu_cortexa53_0 -os standalone
}

puts "(VideoSigXilinx) Importing main application..."
importprojects $app_name

puts "(VideoSigXilinx) Importing other sources..."
# The following command could probably be replaced with
# 'createlib' in the future (library project).
# This would also remove the need to gitignore imported source files.
importsources -name $app_name -path src

puts "(VideoSigXilinx) Loaded projects:"
set projects [getprojects]
set i 0
foreach proj $projects {
  incr i
  puts "\t($i) $proj"
}

if {[catch {
  puts "(VideoSigXilinx) Building all projects..."
  projects -build
} errmsg ]} {
  puts "(VideoSigXilinx) Failed building all projects!"
  puts "(VideoSigXilinx) Error information:"
  puts "ErrorMsg: $errmsg"
  puts "ErrorCode: $errorCode"
  puts "ErrorInfo:\n$errorInfo\n"
  exit 1
}
