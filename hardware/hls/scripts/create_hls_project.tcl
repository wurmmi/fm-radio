#-------------------------------------------------------------------------------
# File        : create_hls_project.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Create Vivado HLS project.
#-------------------------------------------------------------------------------

source ../../scripts/hls_defines.tcl

set project_name [lindex $argv 2]

# Create project
open_project -reset $project_name

# Design files
puts "### HLS IP Design sources"
add_files      $SRC_DIR_IP/filter_coeff_headers/filter_bp_lrdiff.h
add_files      $SRC_DIR_IP/filter_coeff_headers/filter_bp_pilot.h
add_files      $SRC_DIR_IP/filter_coeff_headers/filter_lp_mono.h
add_files      $SRC_DIR_IP/fm_global_spec.hpp
add_files      $SRC_DIR_IP/fm_global.hpp
add_files      $SRC_DIR_IP/utils/strobe_gen.hpp
add_files      $SRC_DIR_IP/utils/strobe_gen.cpp                   -cflags $CPPFLAGS
add_files      $SRC_DIR_IP/utils/decimator.hpp
add_files      $SRC_DIR_IP/utils/fir.hpp
add_files      $SRC_DIR_IP/utils/delay.hpp
add_files      $SRC_DIR_IP/utils/fm_demodulator.hpp
add_files      $SRC_DIR_IP/utils/fm_demodulator.cpp               -cflags $CPPFLAGS
add_files      $SRC_DIR_IP/channel_decoder/recover_carriers.hpp
add_files      $SRC_DIR_IP/channel_decoder/recover_carriers.cpp   -cflags $CPPFLAGS
add_files      $SRC_DIR_IP/channel_decoder/recover_lrdiff.hpp
add_files      $SRC_DIR_IP/channel_decoder/recover_lrdiff.cpp     -cflags $CPPFLAGS
add_files      $SRC_DIR_IP/channel_decoder/recover_mono.hpp
add_files      $SRC_DIR_IP/channel_decoder/recover_mono.cpp       -cflags $CPPFLAGS
add_files      $SRC_DIR_IP/channel_decoder/separate_lr_audio.hpp
add_files      $SRC_DIR_IP/channel_decoder/separate_lr_audio.cpp  -cflags $CPPFLAGS
add_files      $SRC_DIR_IP/channel_decoder.hpp
add_files      $SRC_DIR_IP/channel_decoder.cpp                    -cflags $CPPFLAGS
add_files      $SRC_DIR_IP/fm_receiver.hpp
add_files      $SRC_DIR_IP/fm_receiver.cpp                        -cflags $CPPFLAGS
add_files      $SRC_DIR_IP/fm_receiver_hls.hpp
add_files      $SRC_DIR_IP/fm_receiver_hls.cpp                    -cflags $CPPFLAGS

# Testbench files
puts "### Testbench firmware sources"
add_files -tb  $SRC_DIR_FW/FileReader/FileReader.h
add_files -tb  $SRC_DIR_FW/FileReader/FileReader.cpp              -cflags $CPPFLAGS
add_files -tb  $SRC_DIR_FW/FileReader/WavReader.h
add_files -tb  $SRC_DIR_FW/FileReader/WavReader.cpp               -cflags $CPPFLAGS

# Testbench
puts "### Testbench firmware sources"
file mkdir     $SRC_DIR_TB/output/
add_files -tb  $SRC_DIR_TB/output/
add_files -tb  $SRC_DIR_TB/helper/DataLoader.hpp
add_files -tb  $SRC_DIR_TB/helper/DataWriter.hpp
add_files -tb  $SRC_DIR_TB/main.cpp                               -cflags $CPPFLAGS

# Solution settings
open_solution -reset "solution1"

set_top fm_receiver_hls
set_part {xc7z020clg484-1}
create_clock -period 10 -name default
config_rtl -reset control -reset_level low

exit
