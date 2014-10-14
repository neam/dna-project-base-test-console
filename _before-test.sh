#!/bin/bash

set -x;

echo "Note: When running or sourcing this script, you must reside within the tests folder of the component you want to test"

if [ "$0" == "-bash" ] || [ "$0" == "bash" ]; then
    echo "Assuming running sourced"
    $script_path=$(pwd)
else
    script_path=`dirname $0`
    cd $script_path
    # fail on any error
    set -o errexit
fi

if [ "$(basename $script_path/..)" == "dna" ]; then
    # assume we are testing the dna
    export PROJECT_BASEPATH=$(pwd)/../..
else
    # assume we are testing a yiiapp under yiiapps/
    export PROJECT_BASEPATH=$(pwd)/../../..
fi

export TESTS_BASEPATH=$(pwd)
export TESTS_FRAMEWORK_BASEPATH=$PROJECT_BASEPATH/vendor/neam/yii-dna-test-framework
export TESTS_BASEPATH_REL=$(python -c "import os.path; print os.path.relpath('$TESTS_BASEPATH', '$TESTS_FRAMEWORK_BASEPATH')")

# run composer install on both app and tests directories
cd $TESTS_BASEPATH/..
php $PROJECT_BASEPATH/composer.phar install --prefer-source
cd $TESTS_FRAMEWORK_BASEPATH
php $PROJECT_BASEPATH/composer.phar install --prefer-source

# defaults

if [ "$COVERAGE" == "" ]; then
    export COVERAGE=full
fi

php $PROJECT_BASEPATH/vendor/neam/php-app-config/export.php | tee /tmp/php-app-config.sh
source /tmp/php-app-config.sh

cd $TESTS_BASEPATH
echo "DROP DATABASE IF EXISTS $TEST_DB_NAME; CREATE DATABASE $TEST_DB_NAME;" | mysql -h$TEST_DB_HOST -P$TEST_DB_PORT -u$TEST_DB_USER --password=$TEST_DB_PASSWORD

cd $TESTS_FRAMEWORK_BASEPATH
erb $TESTS_FRAMEWORK_BASEPATH/codeception.yml.erb > $TESTS_BASEPATH/codeception.yml

cd $TESTS_BASEPATH
./generate-local-codeception-config.sh
$TESTS_FRAMEWORK_BASEPATH/vendor/bin/codecept build

# function codecept for easy access to codecept binary
function codecept () {
    $TESTS_FRAMEWORK_BASEPATH/vendor/bin/codecept $@
}
export -f codecept