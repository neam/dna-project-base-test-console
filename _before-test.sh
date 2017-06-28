#!/bin/bash

set -x;

echo "Note: When sourcing this script, you must reside within the tests folder of the component you want to test"

echo "Assuming running sourced"
script_path=$(pwd)

# find the project basepath by looking for the .env file
if [ -f $(pwd)/../.env ]; then
    export PROJECT_BASEPATH=$(pwd)/..
fi
if [ -f $(pwd)/../../.env ]; then
    export PROJECT_BASEPATH=$(pwd)/../..
fi
if [ -f $(pwd)/../../../.env ]; then
    export PROJECT_BASEPATH=$(pwd)/../../..
fi
if [ -f $(pwd)/../../../../.env ]; then
    export PROJECT_BASEPATH=$(pwd)/../../../..
fi
if [ "$PROJECT_BASEPATH" == "" ]; then
  echo "Project base path not found - no .env file in the closes parent directories"
  exit 1
fi

export TESTS_BASEPATH=$(pwd)
export TESTS_FRAMEWORK_BASEPATH=$PROJECT_BASEPATH/vendor/neam/dna-project-base-testing-setup
export TESTS_BASEPATH_REL=$(python -c "import os.path; print os.path.relpath('$TESTS_BASEPATH', '$TESTS_FRAMEWORK_BASEPATH')")

# defaults

if [ "$COVERAGE" == "" ]; then
    export COVERAGE=full
fi

if [[ "$DATA" != test-* ]]; then
  echo "* Prefixing the current data profile with test-, so that there is less risk that tests run against live data";
  export DATA=test-$DATA
fi

cd $PROJECT_BASEPATH
source vendor/neam/php-app-config/shell-export.sh
cd -

cd $TESTS_FRAMEWORK_BASEPATH
erb $TESTS_FRAMEWORK_BASEPATH/codeception.yml.erb > $TESTS_BASEPATH/codeception.yml

cd $TESTS_BASEPATH
./generate-local-codeception-config.sh
$TESTS_FRAMEWORK_BASEPATH/vendor/bin/codecept build

#XDEBUG_PROFILING_PREFIX="php -dxdebug.profiler_enable=1"
XDEBUG_PROFILING_PREFIX=""

# function codecept for easy access to codecept binary running with proper config
function codecept () {
    echo time $XDEBUG_PROFILING_PREFIX $TESTS_FRAMEWORK_BASEPATH/vendor/bin/codecept $@;
    time $XDEBUG_PROFILING_PREFIX $TESTS_FRAMEWORK_BASEPATH/vendor/bin/codecept $@
}
export -f codecept
# helper functions
function test_console () {
    $PROJECT_BASEPATH/vendor/bin/yii-dna-pre-release-testing-console $@
}
export -f test_console
function stop_api_mock_server () {
    pid=$(ps aux | grep node/bin/api-mock | grep -v grep | head -n 1 | awk '{ print $2 }')
    if [ "$pid" != "" ]; then
        kill $pid
    fi
}
export -f stop_api_mock_server
function start_api_mock_server () {
    installed=$(which api-mock || true)
    if [ "$installed" == "" ]; then
        npm -g install api-mock
    fi
    stop_api_mock_server
    api-mock $@ --port 3000 &
}
export -f start_api_mock_server
