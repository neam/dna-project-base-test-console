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

echo "* Resetting codeception db-dependent data (codeception/_data/dump-db-dependent.$DATA.sql) manually for data profile $DATA";

if [ -f $PROJECT_BASEPATH/dna/tests/codeception/_data/dump-db-dependent.$DATA.sql ]; then
    mysql --no-auto-rehash --host=$DATABASE_HOST --port=$DATABASE_PORT --user=$DATABASE_USER --password=$DATABASE_PASSWORD $DATABASE_NAME < $PROJECT_BASEPATH/dna/tests/codeception/_data/dump-db-dependent.$DATA.sql
else
    echo "Data dump codeception/_data/dump-db-dependent.$DATA.sql not found"
fi
