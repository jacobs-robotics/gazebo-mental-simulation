#!/bin/bash
source config/containers.cfg

if [ "$#" -gt "0" ]; then
    # a container name was specified
    echo -e "${GREEN}>>> Stopping $1 container...${NC}"
    docker kill $1 &> /dev/null
else
    # kill all running containers
    if [ ${#containers} -gt 0 ]; then
        echo -e "${GREEN}>>> Stopping all ${image_name} containers...${NC}"
        docker kill ${containers} &> /dev/null
    fi
fi
