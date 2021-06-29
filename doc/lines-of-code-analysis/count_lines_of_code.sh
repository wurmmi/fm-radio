#-------------------------------------------------------------------------------
# File        : count_lines_of_code.sh
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Count lines of code in this repository and produce a statistic.
#-------------------------------------------------------------------------------

cloc hardware/vhdl/ip/rtl/ --by-file --not-match-f="fixed_"
