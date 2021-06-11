################################################################################
# File        : create_sdk.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Set up an SDK project.
#               Creates Hardware Platform, Board Support Package and
#               imports the application project, with additional sources.
################################################################################

set origin_dir [file dirname [info script]]
set workspace_dir [file normalize "${origin_dir}/../sdk"]

set open_gui [lindex $argv 0]

set design_name "proj"

set hw_name ${design_name}_wrapper_hw_platform_0
set bsp_name freertos10_xilinx_bsp_0
set app_name fm_radio_app

puts "(MWURM) Opening SDK..."

setws $workspace_dir
cd $workspace_dir
puts "(MWURM) Set workspace to '[getws]'."

puts "(MWURM) Creating HW platform..."
if {![file exists "$hw_name"]} {
  createhw -name $hw_name -hwspec latest_bin/${design_name}_wrapper.hdf

  # Create driver files
  # NOTE: This is not documented in the XSCT UG1208
  getperipherals $hw_name/system.hdf
}
# Replace the auto-generated bitfile with the 'real' one.
file copy -force latest_bin/${design_name}_wrapper.bit $hw_name

puts "(MWURM) Creating BSP..."
if {![file exists "$bsp_name"]} {
  createbsp -name $bsp_name -hwproject $hw_name -proc ps7_cortexa9_0 -os freertos10_xilinx
}

puts "(MWURM) Adding libraries to BSP..."
setlib -bsp $bsp_name -lib xilffs

puts "(MWURM) Editing options of FreeRTOS ..."
configbsp -bsp $bsp_name/system.mss total_heap_size 512000

puts "(MWURM) Update and re-generate BSP ..."
updatemss -mss $bsp_name/system.mss
regenbsp -bsp $bsp_name

puts "(MWURM) Importing main application..."
importprojects $app_name

#puts "(MWURM) Importing other sources..."
# The following command could probably be replaced with
# 'createlib' in the future (library project).
# This would also remove the need to gitignore imported source files.
#importsources -name $app_name -path src/

puts "(MWURM) Loaded projects:"
set projects [getprojects]
set i 0
foreach proj $projects {
  incr i
  puts "\t($i) $proj"
}

if {$open_gui == 0} {
  if {[catch {
    puts "(MWURM) Building all projects..."
    projects -build
  } errmsg ]} {
    puts "(MWURM) Failed building all projects!"
    puts "(MWURM) Error information:"
    puts "ErrorMsg: $errmsg"
    puts "ErrorCode: $errorCode"
    puts "ErrorInfo:\n$errorInfo\n"
    exit 1
  }
}
