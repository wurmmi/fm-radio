
PROJECT_ROOT="$( cd "$(dirname "$BASH_SOURCE")/../.." >/dev/null 2>&1 ; pwd -P )"

if [ $BASH_SOURCE == $0 ];then
    echo "Failure, this script must be called with source"
    echo "e.g. \"source setup_env.sh\""
    exit 1
fi

echo "### Python environment"

export PYTHONPATH=$PROJECT_ROOT/hardware/tb/packages/fixed_point

echo "Done."
