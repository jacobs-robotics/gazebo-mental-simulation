#!/bin/bash

TIME=`date +%Y%m%d%H%M%S`

cd ~/experiments/sda/
mkdir -p current_run
mkdir -p current_run/$TIME
# ignore errors by appending "|| :" in case a file was not found
mv -f logs/results.txt current_run/$TIME || :
mv -f node_results.csv current_run/$TIME || :
