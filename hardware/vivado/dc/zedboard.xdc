#-------------------------------------------------------------------------------
# file:        zedboard.xdc
# author:      Michael Wurm <wurm.michael95@gmail.com>
# description: Pin constraints for Zedboard
#-------------------------------------------------------------------------------


#===============================================================================
# Pin Assignments
#===============================================================================

# --- Audio interface ----------------------------------------------------------

set_property PACKAGE_PIN AA6     [get_ports bclk]
set_property PACKAGE_PIN Y6      [get_ports lrclk]
set_property PACKAGE_PIN Y8      [get_ports sdata]

# --- Other --------------------------------------------------------------------

set_property PACKAGE_PIN T22 [get_ports heartbeat]

#===============================================================================
# IOSTANDARD Constraints
#===============================================================================

# --- Audio interface ------------------------------------------------------------

set_property IOSTANDARD LVCMOS33 [get_ports bclk]
set_property IOSTANDARD LVCMOS33 [get_ports lrclk]
set_property IOSTANDARD LVCMOS33 [get_ports sdata]

# --- Other --------------------------------------------------------------------

set_property IOSTANDARD LVCMOS33 [get_ports heartbeat]
