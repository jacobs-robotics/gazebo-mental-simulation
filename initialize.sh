#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
source $parent_path/config/containers.cfg

for ((container_index=1; container_index<=$num_containers; container_index++))
do
    container=${image_name}${container_index}

    echo -e "${GREEN}>>> Initializing "$container" container...${NC}"
    
    if [ -d /sys/module/nvidia ]; then
        echo -e "${GREEN}>>> Using Nvidia graphics.${NC}"
        NVIDIA_ARGS=""
        for f in `ls /dev | grep nvidia`; do
            NVIDIA_ARGS="$NVIDIA_ARGS --volume=/dev/${f}:/dev/${f}:rw"
        done

        NVIDIA_ARGS="$NVIDIA_ARGS --privileged"
    elif [ -d /dev/dri ]; then
        echo -e "${GREEN}>>> Using Intel graphics.${NC}"
        DRI_ARGS=""
        for f in `ls /dev/dri/*`; do
            DRI_ARGS="$DRI_ARGS --device=$f"
        done

        DRI_ARGS="$DRI_ARGS --privileged"
    fi
        
    docker create -it \
        $NVIDIA_ARGS \
        $DRI_ARGS \
        --user="${userid}" \
        --name="${container}" \
        --hostname="${container}" \
        --net=default \
        --label="${image_name}" \
        --env="DISPLAY" \
        --env="QT_X11_NO_MITSHM=1" \
        --workdir="/home/${user}" \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --volume="/tmp/nvidia:/tmp/nvidia:rw" \
        --volume=`pwd`/${image_name}/src:/home/${user}/${image_name}/src \
        --volume=`pwd`/gazebo_models:/home/${user}/.gazebo/models \
        --volume=`pwd`/results:/home/${user}/results \
        --volume=`pwd`/logs:/home/${user}/logs \
        --volume=`pwd`/ros_logs:/home/${user}/.ros/log \
        --volume=`pwd`/world_files:/home/${user}/world_files \
        ${image_name}
        
        # error code 1 is harmless (meaning the container has been created already beforehand)
        rc=$?; if [[ $rc != 0 && $rc != 1 ]]; then exit $rc; fi
        
    echo -e "${GREEN}>>> Done initializing "$container" container${NC}"

done
