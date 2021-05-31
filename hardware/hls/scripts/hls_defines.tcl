#-------------------------------------------------------------------------------
# File        : hls_defines.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Some defines for the HLS project.
#-------------------------------------------------------------------------------

set SRC_DIR  "../../src"
set TB_DIR   "../../tb"

set GIT_HASH   [exec git rev-parse --short HEAD]
set BUILD_TIME [clock format [clock seconds] -format "%y%m%d%H%M%S"]

puts "GIT_HASH   : $GIT_HASH"
puts "BUILD_TIME : $BUILD_TIME"

set CPPFLAGS "-O0 --std=c++11 -I$SRC_DIR     \
              -Wall                          \
              -Wno-unused-label              \
              -Wno-unused-parameter          \
              -Wno-mismatched-tags           \
              -DGIT_HASH=$GIT_HASH           \
              -DBUILD_TIME=$BUILD_TIME"


#              -fsanitize=undefined"
