#!/bin/bash
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m' # no color

# restart scene generation from time to time to make sure nothing stalls - existing scenes will be skipped
TIMEOUT="15m"
LAUNCH_FILE_NAME="parcelrobot_generate_random_scene.launch"
#LAUNCH_FILE_NAME="pr2_generate_random_scene.launch"

# stop container if running
docker kill sda1 &> /dev/null
# wait until the container has been stopped
until [ "`/usr/bin/docker inspect -f {{.State.Running}} sda1`" == "false" ]; do
    sleep 0.1;
done;
# restart container
docker start sda1 &
# wait until the container is officially running
until [ "`/usr/bin/docker inspect -f {{.State.Running}} sda1`" == "true" ]; do
	sleep 0.1;
done;

# loop this infinitely; need to stop random scene generator manually after all scenes have been generated
while :
do
    # start random scene generation
    timeout --signal=SIGKILL $TIMEOUT docker exec -t sda1 /bin/bash -c ". /usr/share/gazebo/setup.sh && . /home/tobi/sda/devel/setup.bash && roslaunch scene_dynamics_anticipation $LAUNCH_FILE_NAME gui:=false"
    # stop container
    docker kill sda1 &> /dev/null
    # wait until the container has been stopped
	until [ "`/usr/bin/docker inspect -f {{.State.Running}} sda1`" == "false" ]; do
		sleep 0.1;
	done;
    # start container
	docker start sda1 &
	# wait until the container is officially running
	until [ "`/usr/bin/docker inspect -f {{.State.Running}} sda1`" == "true" ]; do
		sleep 0.1;
	done;
done
