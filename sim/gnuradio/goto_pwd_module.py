# ----------------------------------------------------------------------------
# File        : goto_pwd_module.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Helper for the GNURadio script, to change the current path
#               to the scripts directory.
#               Therefor, relative paths can be used in the GNURadio script.
# ----------------------------------------------------------------------------

import os

script_path = os.path.dirname(os.path.realpath(__file__))
os.chdir(script_path)
