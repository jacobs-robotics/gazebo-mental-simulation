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
    # install Nvidia driver if this system uses Nvidia graphics
    # this can be done here only because we need to mount the graphics driver into the container and this works only when the container has been started before
    if test -f /tmp/nvidia/NVIDIA.run; then
        if ! test -f /tmp/nvidia/NVIDIA.installed; then
            echo -e "${GREEN}>>> Installing Nvidia graphics driver...${NC}"
            docker exec -it --user="root" ${container} /bin/bash -c ". /home/${user}/${image_name}/devel/setup.bash && if test -f /tmp/nvidia/NVIDIA.run; then if ! test -f /tmp/nvidia/NVIDIA.installed; then chmod +x /tmp/nvidia/NVIDIA.run && ( /bin/sh /tmp/nvidia/NVIDIA.run -s --no-kernel-module ) && touch /tmp/nvidia/NVIDIA.installed; fi; fi";
            ./stop.sh
            docker start $INTERACTIVE ${container} &
            # wait until the container is officially running
            until [ "`/usr/bin/docker inspect -f {{.State.Running}} ${container}`" == "true" ]; do
                sleep 0.1;
            done;
        fi
    fi
done
