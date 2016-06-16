#!/bin/bash
#
# Run test tshark's dissectors on small test files

set -e

for testcase in tests/*/*.pdml; do
    cd $(dirname $testcase)
    test_file=$(basename $testcase)
    tshark -T pdml -r ${test_file%%.pdml} > out.pdml 2>&1 ;
    xsltproc filter.xsl out.pdml | diff $test_file -
    rm out.pdml
    cd ../../
done
