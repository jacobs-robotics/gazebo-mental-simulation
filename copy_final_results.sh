#!/bin/bash

TIME=`date +%Y%m%d%H%M%S`

cd ~/experiments/sda/
# ignore errors by appending "|| :" in case a file was not found or no connection could be established
mv -f final_results.csv current_run || :
mv -f training_data/* current_run || :
mv -f current_run ml_results/$TIME || :
scp -r ml_results/$TIME tobi@10.70.15.137:/home/tobi/experiments/sda/ml_results || :
