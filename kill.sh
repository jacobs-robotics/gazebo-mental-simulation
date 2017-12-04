#!/bin/bash
GREEN='\033[1;32m'
NC='\033[0m' # no color

echo -e "${GREEN}>>> Stopping all containers and scripts...${NC}"

# kill scripts
killall sda_process.sh &>/dev/null
killall sda.sh &>/dev/null

# kill all running containers
current_containers=$(docker ps -a --filter="label=gazebo-mental-simulation" --format "{{.Names}}")
if [ ${#current_containers} -gt 0 ]; then
    docker kill ${current_containers} &> /dev/null
fi

killall sda_process.sh &>/dev/null
killall sda.sh &>/dev/null
