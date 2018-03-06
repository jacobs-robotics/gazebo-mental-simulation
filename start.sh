#!/bin/bash
# start all containers (use "-i" for interactvity)
source config/containers.cfg

EXIST_OPTION=0
INTERACTIVE=""
GUI="false"

if [[ ($# -gt 0 && $1 == "-i") ]]; then
    EXIST_OPTION=1
    echo -e "${GREEN}>>> Starting containers with interactive option...${NC}"
    INTERACTIVE="-i"
    GUI="true"
fi

# start all containers
for container in ${containers}
do
	echo -e "${GREEN}>>> Starting "$container" container...${NC}"
    # make X connections possible from any host
    xhost +local:`docker inspect --format='{{ .Config.Hostname }}' ${container}` > /dev/null
	docker start $INTERACTIVE ${container} &
	# wait until the container is officially running
	until [ "`/usr/bin/docker inspect -f {{.State.Running}} ${container}`" == "true" ]; do
		sleep 0.1;
	done;
done
