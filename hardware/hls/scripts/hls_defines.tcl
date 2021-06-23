#-------------------------------------------------------------------------------
# File        : hls_defines.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Some defines for the HLS project.
#-------------------------------------------------------------------------------

set SRC_DIR_IP  "../../src"
set SRC_DIR_TB  "../../tb"
set SRC_DIR_FW  "../../../vivado/sdk/fm_radio_app/src"

set GIT_HASH   "0x[exec git describe --always --abbrev=8]"
set BUILD_TIME "0x[clock format [clock seconds] -format "%y%m%d%H%M%S" -timezone UTC]"

set CPPFLAGS_AVOID_HLS_STDLIB_WARNINGS [ list \
  -Wno-unused-label                           \
  -Wno-unused-parameter                       \
  -Wno-mismatched-tags                        \
  -Wno-unused-function                        \
  -Wno-misleading-indentation                 \
]

set CPPFLAGS_COMMON [ list                    \
  -O0                                         \
  -std=gnu++11                                \
  -I$SRC_DIR_IP                               \
  -Wall                                       \
  {*}$CPPFLAGS_AVOID_HLS_STDLIB_WARNINGS      \
  -DBUILD_TIME=${BUILD_TIME}                  \
  -DGIT_HASH=${GIT_HASH}                      \
]
#  -fsanitize=undefined"

set CPPFLAGS_CSIM [ list                      \
  {*}$CPPFLAGS_COMMON                         \
  -I$SRC_DIR_FW                               \
  -I$SRC_DIR_FW/utils                         \
  -D__CSIM__                                  \
]

set CPPFLAGS_COSIM [ list                     \
  {*}$CPPFLAGS_COMMON                         \
  -I$SRC_DIR_FW                               \
  -D__RTL_SIMULATION__                        \
]

puts "GIT_HASH        : $GIT_HASH"
puts "BUILD_TIME      : $BUILD_TIME"
puts "CPPFLAGS_COMMON : $CPPFLAGS_COMMON"
puts "CPPFLAGS_CSIM   : $CPPFLAGS_CSIM"
puts "CPPFLAGS_COSIM  : $CPPFLAGS_COSIM"
