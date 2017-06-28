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

# run composer install on both app and tests directories
cd $TESTS_BASEPATH/..
php $PROJECT_BASEPATH/composer.phar install --prefer-source --optimize-autoloader
cd $TESTS_FRAMEWORK_BASEPATH
php $PROJECT_BASEPATH/composer.phar install --prefer-source --optimize-autoloader
cd "$TESTS_BASEPATH"
