#-------------------------------------------------------------------------------
# File        : hls_defines.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Some defines for the HLS project.
#-------------------------------------------------------------------------------

set SRC_DIR  "../../src"
set TB_DIR   "../../tb"

set GIT_HASH   "0x[exec git rev-parse --short HEAD]"
set BUILD_TIME "0x[clock format [clock seconds] -format "%y%m%d%H%M%S"]"

set CPPFLAGS [ list                            \
                -O0                            \
                -std=gnu++11                   \
                -I$SRC_DIR                     \
                -Wall                          \
                -Wno-unused-label              \
                -Wno-unused-parameter          \
                -Wno-mismatched-tags           \
                -DBUILD_TIME=${BUILD_TIME}     \
                -DGIT_HASH=${GIT_HASH}         \
              ]
#              -fsanitize=undefined"

puts "GIT_HASH   : $GIT_HASH"
puts "BUILD_TIME : $BUILD_TIME"
puts "CPPFLAGS   : $CPPFLAGS"
