#!/bin/bash
# run SDA for all world files in a folder
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m' # no color

# path where the "experiments.todo" and "experiments.done" folders are located
WORLDFILE_PATH=./sda/src/scene_dynamics_anticipation_meta/scene_dynamics_anticipation_launch/worlds/
# number of repetitions for a single world file in order to compensate for motion planning noise and irrelevant pairwise preferences
NUM_REPETITIONS=100
# determine if headless Gazebo shall be used (on rack etc.); use "export" to make this variable appear in sub-scripts (sda_process.sh, sda.sh)
export HEADLESS="true"

# remove old data
./clear_results.sh
# stop containers if running
./stop.sh
./start.sh

# determine number of containers to use in parallel
ALL_CONTAINERS=("sda1" "sda2" "sda3" "sda4")
if [[ ($# == 1) ]]; then
    NUM_CONTAINERS=$1
else
    NUM_CONTAINERS=${#ALL_CONTAINERS[@]}
fi
CONTAINERS=("${ALL_CONTAINERS[@]:0:$NUM_CONTAINERS}")

CONTAINER_INDEX=0

# run for all world files, assuming that the directory structure inside and outside of the container is similar
# on the command line, something like '`rospack find scene_dynamics_anticipation_launch`/worlds/blah.world' can be used
for world_file in $(docker exec --user="`id -u -n`" sda1 /bin/bash -c '. /home/`id -u -n`/sda/devel/setup.bash && ls `rospack find scene_dynamics_anticipation_launch`/worlds/experiments.todo/*.world')
do
    # perform SDA run using next container
    export DISPLAY_ID=$((CONTAINER_INDEX+1))
    ./sda_process.sh ${CONTAINERS[$((CONTAINER_INDEX))]} $WORLDFILE_PATH $world_file $NUM_REPETITIONS &
    # increment container index
    CONTAINER_INDEX=$((($CONTAINER_INDEX+1)%$NUM_CONTAINERS))
    # wait for all containers to finish
    if [[ ($CONTAINER_INDEX == 0) ]]; then
        wait
    fi
done

# copy final results
./copy_final_results.sh
