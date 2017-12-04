#!/bin/bash
source config/containers.cfg

if [ ${#containers} -gt 0 ]; then
    echo -e "${GREEN}>>> Deleting existing Docker containers.${NC}"
    docker kill ${containers} &> /dev/null
    docker rm -f ${containers} &> /dev/null
else
    echo -e "${GREEN}>>> No Docker containers are currently running!${NC}" 
fi

if [ "$1" == "-i" ]; then
    echo -e "${YELLOW}>>> Remove and recreate images (in addition to containers)?${NC}"
    read -p "<y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
        images=$(docker images -aq ${image_name})
        if [ ${#images} -gt 0 ]; then
            echo -e "${GREEN}>>> Deleting existing Docker images.${NC}"
            docker rmi -f ${images} &> /dev/null
        else 
            echo -e "${GREEN}>>> No Docker images are currently existing!${NC}" 
        fi
    fi
fi
