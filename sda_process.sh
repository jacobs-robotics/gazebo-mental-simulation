#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
NC='\033[0m' # no color
user=`id -u -n`

echo -e "${GREEN}>>> Using container ${BLUE}$1${GREEN} and world file ${BLUE}`basename $3`${GREEN} with ${BLUE}$4${GREEN} repetitions.${NC}"

# use "false" as default argument in case this variable has not been set outside
HEADLESS=${HEADLESS:-"false"}
DISPLAY_ID=${DISPLAY_ID:-1}

TRAINING_DATA_PATH="/home/${user}/experiments/sda/training_data/"

TRAINING_DATA_FILE=$TRAINING_DATA_PATH/`basename $3`.data
NUM_LINES_TRAINING_FILE=0
while [ $NUM_LINES_TRAINING_FILE -lt $4 ]; do
    echo -e "${GREEN}>>> Repetition #$((${NUM_LINES_TRAINING_FILE}+1))...${NC}"
    # run SDA script using container name and world file name
    ./sda.sh $1 $3
    # determine length of training file (in lines)
    IFS=' ' read -r -a array <<< `wc -l $TRAINING_DATA_FILE`
    NUM_LINES_TRAINING_FILE=$((${array[0]} - 1)) # -1 because of the header
done
# on the last repetition, dump the training data which has been accumulated for the current world file
./sda.sh -d $1 $3

# copy run results
./copy_results.sh
# move world file into "done" folder
# ignore errors by appending "|| :" in case a file was not found
mv $2/experiments.todo/`basename $3` $2/experiments.done/`basename $3` || :
