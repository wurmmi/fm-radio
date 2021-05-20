#-------------------------------------------------------------------------------
# File        : hls_defines.tcl
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Some defines for the HLS project.
#-------------------------------------------------------------------------------

set SRC_DIR  "../../src"
set TB_DIR   "../../tb"

set CPPFLAGS "-O0 --std=c++11 -I$SRC_DIR     \
              -Wall                          \
              -Wno-unused-label              \
              -Wno-unused-parameter          \
              -Wno-mismatched-tags"          \

#              -fsanitize=undefined"
