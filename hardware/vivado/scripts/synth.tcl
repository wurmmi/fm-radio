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
  puts "(VideoSigXilinx) ERROR: Couldn't open project."
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
          puts "(VideoSigXilinx) An error occured in file '$runme_log_file', line $line_ctr."
          puts "(VideoSigXilinx) The error reads: $line"
          close $fp
          exit 1
        }
      }
      close $fp
    }
  }
} ]} {
  puts "(VideoSigXilinx) ERROR: Synthesis failed."
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
    puts "(VideoSigXilinx) ERROR: Implementation returned with progress lower than 100%."
    exit 1
  }
} ]} {
  puts "(VideoSigXilinx) ERROR: Implementation failed."
  exit 1
}

if {[catch {
  puts "--- - Creating bitstream"
  reset_run impl_1 -from_step write_bitstream
  launch_runs impl_1 -to_step write_bitstream -jobs $parallel_jobs
  wait_on_run impl_1
} ]} {
  puts "(VideoSigXilinx) ERROR: Bitstream generation failed."
  exit 1
}

puts "(VideoSigXilinx) Done."
exit 0
