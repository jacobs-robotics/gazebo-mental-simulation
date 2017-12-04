#!/bin/bash
# update all repos from the respective source control
source config/containers.cfg

echo -e "${GREEN}>>> Updating this repository...${NC}"
git pull

# update code inside image
echo -e "${GREEN}>>> Updating ${meta_package_name}...${NC}" \
	&& ( cd $image_name/src \
	&& ( cd ${meta_package_name} && git pull ) \
	&& wstool merge --merge-kill-append -y $meta_package_name/$meta_package_rosinstall_path )
	( cd $image_name/src \
    && wstool up --backup-changed-uris=../backup )

# update experiments repo    
if [ -n "$experiments_repo_uri" ]; then
    echo -e "${GREEN}>>> Updating ${experiments_repo_name} code...${NC}"
    ( cd $experiments_repo_name && git pull )
fi
    
# re-build docker image and containers, in case there are additional dependencies
echo -e "${GREEN}>>> Re-building image because dependencies may have changed...${NC}"
docker build --build-arg user=$user --build-arg userid=$userid --build-arg group=$group --build-arg groupid=$groupid --build-arg image_name=$image_name -t $image_name $image_name || exit $?
echo -e "${GREEN}>>> Re-building containers...${NC}"
for container in ${containers}
do
    echo -e "${GREEN}>>> Building $container container...${NC}"
    docker build --build-arg user=$user --build-arg userid=$userid --build-arg group=$group --build-arg groupid=$groupid --build-arg image_name=$image_name -t $container $image_name || exit $?
    # apt-get install the stuff manually which, weirdly enough, does not work via Dockerfile
    #docker exec -it --user=root ${container} /bin/bash -c "apt-get update && apt-get install -y ros-indigo-rviz-visual-tools ros-indigo-pr2-controllers-msgs libignition-math2-dev"
done

