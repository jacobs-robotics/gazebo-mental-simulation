#!/bin/bash
# mount and build all code inside the containers
source config/containers.cfg

./initialize.sh

if [[ ($# -gt 0 && $1 == "-k") ]]; then
    KEEP_STARTED=1
    echo -e "${GREEN}>>> Keeping containers started after build!${NC}"
fi

./start.sh

for container in ${containers}
do
    docker start -i ${container} &
    # wait until the container is officially running
    until [ "`/usr/bin/docker inspect -f {{.State.Running}} ${container}`" == "true" ]; do
        sleep 0.1;
    done;
done

# build all containers
for container in ${containers}
do
	echo -e "${GREEN}>>> Building code inside "$container" container...${NC}"
    
    # apt-get install the stuff manually which, weirdly enough, does not work via Dockerfile
    #docker exec -it --user=root ${container} /bin/bash -c "apt-get update && apt-get install -y ros-indigo-rviz-visual-tools ros-indigo-pr2-controllers-msgs libignition-math2-dev"
    if [[ "$build_meta_package_only" == "true" ]]; then
        docker exec -it --user="${user}" ${container} /bin/bash -c ". /home/${user}/${image_name}/devel/setup.bash; cd /home/${user}/${image_name}; catkin build -j${num_build_jobs} ${meta_package_name}" || exit $?
    else
        docker exec -it --user="${user}" ${container} /bin/bash -c ". /home/${user}/${image_name}/devel/setup.bash; cd /home/${user}/${image_name}; catkin build -j${num_build_jobs}" || exit $?
    fi

    # install Python voting stuff - this works here only because the volumes have not been mounted before
    #docker exec -it --user=root ${container} /bin/bash -c "cd /home/${user}/sda/src/python-vote-core; python setup.py install" || exit $?

    if [[ "$KEEP_STARTED" -ne "1" ]]; then
        ./stop.sh ${container}
    fi
done

