################################################################################
# File        : setup_env.sh
# Author      : Stefan Jahn <stefan.jahn332@gmail.com>
#               Michael Wurm <wurm.michael95@gmail.com>
# Description : Set up environment for cocotb testbench.
################################################################################

PROJECT_ROOT="$( cd "$(dirname "$BASH_SOURCE")/../../.." >/dev/null 2>&1 ; pwd -P )"

if [ $BASH_SOURCE == $0 ]; then
    echo "Failure, this script must be called with source"
    echo "e.g. \"source setup_env.sh\""
    exit 1
fi

echo "### Python environment"

export PYTHONPATH=
export PYTHONPATH=$PYTHONPATH:$PROJECT_ROOT/hardware/common/tb/packages/fixed_point
export PYTHONPATH=$PYTHONPATH:$PROJECT_ROOT/hardware/common/tb/packages/helpers
export PYTHONPATH=$PYTHONPATH:$PROJECT_ROOT/hardware/common/tb/packages/fm_global
export PYTHONPATH=$PYTHONPATH:$PROJECT_ROOT/hardware/common/tb/packages/fm_receiver_model
export PYTHONPATH=$PYTHONPATH:$PROJECT_ROOT/hardware/common/tb/packages/tb_analyzer
export PYTHONPATH=$PYTHONPATH:$PROJECT_ROOT/hardware/vhdl/tb/packages/vhdl_sampler

echo "Done."
