#!/bin/bash

#set -x;

script_path=`dirname $0`
cd $script_path/..

# fail on any error
set -o errexit

if [[ "$PROJECT_BASEPATH" == "" ]]; then
  echo "Test shell is not properly bootstrapped for tests. Please run 'source bashrc/before-test.sh' then try again"
  exit 1
fi

if [[ "$DATA" != test-* ]]; then
  echo "* Prefixing the current data profile with test-, so that there is less risk that tests run against live data";
  export DATA=test-$DATA
fi

cd $PROJECT_BASEPATH
source vendor/neam/php-app-config/shell-export.sh
cd -

time $PROJECT_BASEPATH/bin/reset-db.sh;
time test_console mysqldump --dumpPath=dna/tests/codeception/_data/ --dumpFile=dump-db-dependent.$DATA.sql
sed -i -e 's/\/\*!50013 DEFINER=`[^`]*`@`[^`]*` SQL SECURITY DEFINER \*\///' $PROJECT_BASEPATH/dna/tests/codeception/_data/dump-db-dependent.$DATA.sql
echo "* Codeception is set to reload the profile $DATA between tests (codeception/_data/dump-db-dependent.$DATA.sql)."
