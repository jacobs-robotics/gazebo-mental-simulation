#!/bin/bash
# start gazebo-mental-simulation containers (non-interactive)
GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # no color
user=`id -u -n`

EXIST_OPTION=0
INTERACTIVE=""
GUI="false"
# use "false" as default argument in case this variable has not been set outside
HEADLESS=${HEADLESS:-"false"}
DISPLAY_ID=${DISPLAY_ID:-1}
VERBOSE="false"
SHUTDOWN="true"
ACCUMULATE_TRAINING_DATA="false"

# Parcelrobot
TIMEOUT="20m"
LAUNCH_FILE_NAME="parcelrobot_sda.launch"

# PR2
#LAUNCH_FILE_NAME="pr2_sda.launch"
#TIMEOUT="45m"

if [[ ($# -gt 0 && $1 == "-i" || $# -gt 1 && $2 == "-i" || $# -gt 2 && $3 == "-i") ]]; then
    EXIST_OPTION=1
    echo -e "${GREEN}>>> Starting container with interactive option...${NC}"
    INTERACTIVE="-i"
    GUI="true"
    VERBOSE="true"
fi

if [[ ($# -gt 0 && $1 == "-k" || $# -gt 1 && $2 == "-k" || $# -gt 2 && $3 == "-k") ]]; then
    echo -e "${GREEN}>>> Keeping container started!${NC}"
    SHUTDOWN="false"
fi

if [[ ($# -gt 0 && $1 == "-d" || $# -gt 1 && $2 == "-d" || $# -gt 2 && $3 == "-d") ]]; then
    echo -e "${GREEN}>>> Accumulating training data after run!${NC}"
    ACCUMULATE_TRAINING_DATA="true"
fi

# check if a world file command was given
if [[ ($# == 1) ]]; then
    echo -e "${RED}>>> ERROR: Please specify a container name to start!${NC}" >&2
    exit 1;
elif [[ ($# == 2 && $1 != "-k" && $1 != "-i" && $1 != "-d") ]]; then
    space=$1
	WORLD_FILE=$2
elif [[ ($# == 3 && $2 != "-k" && $2 != "-i" && $2 != "-d") ]]; then
    space=$2
	WORLD_FILE=$3
elif [[ ($# == 4 && $3 != "-k" && $3 != "-i" && $3 != "-d") ]]; then
    space=$3
	WORLD_FILE=$4
elif [[ ($# -gt 5) ]]; then
    space=$4
	WORLD_FILE=$5
fi

echo -e "${GREEN}>>> Starting ${space} container...${NC}"
docker start $INTERACTIVE ${space} &
# wait until the container is officially running
until [ "`/usr/bin/docker inspect -f {{.State.Running}} ${space}`" == "true" ]; do
    sleep 0.1;
done;
if [[ ($WORLD_FILE = "") ]]; then
    # use default world
    if $HEADLESS -eq "true"; then
	echo -e "${YELLOW}>>> Using headless operation with display ID ${DISPLAY_ID}!${NC}"
	timeout --signal=SIGKILL $TIMEOUT docker exec $INTERACTIVE -t ${space} /bin/bash -c ". /usr/share/gazebo/setup.sh && (killall -q Xvfb; rm -f /tmp/.X${DISPLAY_ID}-lock; Xvfb :${DISPLAY_ID} -screen 0 1600x1200x16 & export DISPLAY=:${DISPLAY_ID}.0 && . /home/tobi/sda/devel/setup.bash && roslaunch scene_dynamics_anticipation_launch $LAUNCH_FILE_NAME gui:=$GUI verbose:=$VERBOSE shutdown_after_run:=$SHUTDOWN accumulate_training_data:=$ACCUMULATE_TRAINING_DATA)"
    else
	timeout --signal=SIGKILL $TIMEOUT docker exec $INTERACTIVE -t ${space} /bin/bash -c ". /usr/share/gazebo/setup.sh && . /home/tobi/sda/devel/setup.bash && roslaunch scene_dynamics_anticipation_launch $LAUNCH_FILE_NAME gui:=$GUI verbose:=$VERBOSE shutdown_after_run:=$SHUTDOWN accumulate_training_data:=$ACCUMULATE_TRAINING_DATA"
    fi
else
    # check if given world file exists inside the docker container(!)
    if !($(docker exec --user="`id -u -n`" ${space} /bin/bash -c ". /home/`id -u -n`/sda/devel/setup.bash && test -e $WORLD_FILE")); then
      echo -e "${RED}>>> ERROR: World file ${WORLD_FILE} not found inside container!${NC}" >&2
      exit 1
    fi
    # use provided world file
    echo -e "${GREEN}>>> Using world file ${BLUE}"`basename $WORLD_FILE`"${GREEN}.${NC}"
    if $HEADLESS -eq "true"; then
	echo -e "${YELLOW}>>> Using headless operation with display ID ${DISPLAY_ID}!${NC}"
	timeout --signal=SIGKILL $TIMEOUT docker exec $INTERACTIVE -t ${space} /bin/bash -c ". /usr/share/gazebo/setup.sh && (killall -q Xvfb; rm -f /tmp/.X${DISPLAY_ID}-lock; Xvfb :${DISPLAY_ID} -screen 0 1600x1200x16 & export DISPLAY=:${DISPLAY_ID}.0 && . /home/tobi/sda/devel/setup.bash && roslaunch scene_dynamics_anticipation_launch $LAUNCH_FILE_NAME gui:=$GUI verbose:=$VERBOSE shutdown_after_run:=$SHUTDOWN accumulate_training_data:=$ACCUMULATE_TRAINING_DATA world_file:=$WORLD_FILE world_filename:=`basename $WORLD_FILE`)"
    else
	timeout --signal=SIGKILL $TIMEOUT docker exec $INTERACTIVE -t ${space} /bin/bash -c ". /usr/share/gazebo/setup.sh && . /home/tobi/sda/devel/setup.bash && roslaunch scene_dynamics_anticipation_launch $LAUNCH_FILE_NAME gui:=$GUI verbose:=$VERBOSE shutdown_after_run:=$SHUTDOWN accumulate_training_data:=$ACCUMULATE_TRAINING_DATA world_file:=$WORLD_FILE world_filename:=`basename $WORLD_FILE`"
    fi
fi

# shut down container if necessary
if [[ "$SHUTDOWN" == "true" ]]; then
    ./stop.sh ${space}
fi
