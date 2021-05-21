################################################################################
# File        : synth.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Runs synthesis, implementation and creates bitstream for project
################################################################################

set build_dir [lindex $argv 0]

set proj_name "proj"
set parallel_jobs 4

# Open project
if {[catch {
  open_project $build_dir/$proj_name.xpr
} ]} {
  puts "(MWURM) ERROR: Couldn't open project."
  exit 1
}

# Start synthesis
if {[catch {
  puts "--- - Running synthesis"
  reset_run synth_1

  # Launch synthesis
  launch_runs synth_1 -jobs $parallel_jobs
  wait_on_run synth_1

  # Analyze log files in case of an error
  if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    foreach runme_log_file [glob $build_dir/$proj_name.runs/*/*runme.log] {
      set fp [open "$runme_log_file" r]
      set line_ctr 0
      while {[gets $fp line] >= 0} {
        incr line_ctr
        if {[string match -nocase {*ERROR:*} $line]} {
          puts "(MWURM) An error occured in file '$runme_log_file', line $line_ctr."
          puts "(MWURM) The error reads: $line"
          close $fp
          exit 1
        }
      }
      close $fp
    }
  }
} ]} {
  puts "(MWURM) ERROR: Synthesis failed."
  exit 1
}

# Start implementation
if {[catch {
  puts "--- - Running implementation"
  reset_run impl_1

  # Launch implementation
  launch_runs impl_1 -jobs $parallel_jobs
  wait_on_run impl_1

  if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "(MWURM) ERROR: Implementation returned with progress lower than 100%."
    exit 1
  }
} ]} {
  puts "(MWURM) ERROR: Implementation failed."
  exit 1
}

puts "--- - Creating reports"
open_run impl_1

report_utilization -hierarchical -hierarchical_percentages -file $build_dir/$proj_name.runs/impl_1/report_utilization_hierarchical.rpt

if {[catch {
  puts "--- - Creating bitstream"
  reset_run impl_1 -from_step write_bitstream
  launch_runs impl_1 -to_step write_bitstream -jobs $parallel_jobs
  wait_on_run impl_1
} ]} {
  puts "(MWURM) ERROR: Bitstream generation failed."
  exit 1
}

puts "--- - Copying build results"

# Create build result folder
set build_finish_time [clock format [clock seconds] -format %Y%m%d_%H%M%S]
set result_dir $build_dir/results
file mkdir $result_dir

puts "Reports ..."
set build_output_dir $build_dir/$proj_name.runs/impl_1
set report_files [ list                                             \
  "$build_output_dir/${proj_name}_wrapper_utilization_placed.rpt"   \
  "$build_output_dir/report_utilization_hierarchical.rpt"           \
]

foreach report_file $report_files {
  file copy -force $report_file $result_dir
}

puts "Binaries ..."
file copy -force $build_output_dir/${proj_name}_wrapper.bit $result_dir/
file copy -force $build_output_dir/${proj_name}_wrapper.hwdef $result_dir/

puts "Preparing for SDK ..."
set sdk_bin_dir $build_dir/../sdk/latest_bin
file copy -force $result_dir/${proj_name}_wrapper.hwdef $sdk_bin_dir/${proj_name}_wrapper.hdf
file copy -force $result_dir/${proj_name}_wrapper.bit $sdk_bin_dir/

puts "(MWURM) Done."
exit 0
