#!/bin/bash

cd ~/experiments/sda/
# ignore errors by appending "|| :" in case a file was not found
rm -rf current_run || :
rm -f results.txt || :
rm -f node_results.csv || :
rm -f final_results.csv || :
