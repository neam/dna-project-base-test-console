source ../../vendor/neam/dna-project-base-testing-setup/_before-test.sh

set +x;
shopt -s extglob

echo
echo "* You can now run the test suites using:"
echo
echo "  bin/test-db-agnostic.sh"
echo "  bin/test-db-dependent.sh"
echo "  bin/test-db-dependent.sh --skip-db-reset"
echo
echo "* You can also run specific tests using codecept syntax (just make sure that the test you are running make sense for the current DATA env ($DATA):"
echo
for suite_path in codeception/unit_*/; do
  suite=$(basename $suite_path)
  for filepath in codeception/$suite/*+(Test\.php|\.feature); do
    filename=$(basename $filepath)
    echo "  codecept run $suite $filename --debug --fail-fast"
  done
done
echo
echo "* Snippets useful for test creation:"
echo
echo "  codecept gherkin:snippets unit_db_agnostic"
echo "  codecept gherkin:snippets unit_db_dependent"
echo "  codecept g:feature unit_db_dependent clerk-foo"
echo