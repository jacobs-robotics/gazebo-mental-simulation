#!/bin/bash
# initially create containers
source config/containers.cfg

if !(test -e /usr/bin/docker); then
  echo -e "${RED}>>> ERROR: Please install Docker as described on https://docs.docker.com/engine/installation/ !${NC}" >&2
  exit 1
fi

echo -e "${GREEN} Creating Docker containers... During this script, please ignore any messages that are printed in red except if they look like this: ${RED}>>> ERROR ${GREEN}!${NC}" >&2
if !(docker ps &>/dev/null); then
  echo -e "${GREEN}>>> Adding user to docker group (sudo required)...${NC}"
  sudo usermod -aG docker $user
  echo -e "${YELLOW}>>> WARNING: It seems like you were added to the Docker user group just now. Please log out and in again to use the new privileges and try running this script again!${NC}" >&2
  exit 1
fi

# clear existing containers/images
./clear.sh -i

# update this repo first
echo -e "${GREEN}>>> Updating this repository...${NC}"
git pull

# install dependencies
echo -e "${GREEN}>>> Installing dependencies (sudo required)...${NC}"
sudo apt-get install -y python-wstool mercurial xvfb psmisc

# download Gazebo models - use user-provided ones if specified, default ones otherwise
if !(test -e gazebo_models); then
    if [ -n "$gazebo_models_repo_uri" ]; then
        git clone -b $gazebo_models_repo_branch $gazebo_models_repo_uri gazebo_models
    else
        echo -e "${GREEN}>>> Downloading default Gazebo simulation models (this may take a while)...${NC}"
        hg clone https://bitbucket.org/osrf/gazebo_models 
    fi
fi

# make workspace and pull code
echo -e "${GREEN}>>> Downloading code for workspace (this may take a while)...${NC}" \
	&& mkdir -p $image_name/src \
	&& mkdir -p results \
	&& mkdir -p logs \
	&& mkdir -p ros_logs \
	&& mkdir -p world_files
	( cd $image_name/src && git clone -b $meta_package_branch $meta_package_uri $meta_package_name )
	( cd $image_name/src && cp $meta_package_name/$meta_package_rosinstall_path .rosinstall )
	( cd $image_name/src && wstool up --backup-changed-uris=../backup )

# copy world files from meta package
if [ -d "$world_file_path" ]; then
    echo -e "${GREEN}>>> Copying world files from meta package...${NC}"
    cp -r $world_file_path/* world_files
fi
    
# clone external experiments repo if provided
if [ -n "$experiments_repo_uri" ]; then
    echo -e "${GREEN}>>> Downloading experiments code...${NC}"
    git clone -b $experiments_repo_branch $experiments_repo_uri $experiments_repo_name
fi

# download graphics driver if necessary
NVIDIA_VERSION=""
if [ -d /sys/module/nvidia ]; then
	NVIDIA_VERSION=$(cat /sys/module/nvidia/version)
fi
if [[ "$NVIDIA_VERSION" != "" ]]; then
	echo -e "${GREEN}>>> Graphics configuration: Using Nvidia driver.${NC}"
    ./update_nvidia_driver.sh -s
else
	echo -e "${GREEN}>>> Graphics configuration: Using Intel driver. This may or may not work if you use an AMD graphics card.${NC}"
fi

echo -e "${GREEN}>>> Building gazebo-mental-simulation image...${NC}"
docker build --build-arg user=$user --build-arg userid=$userid --build-arg group=$group --build-arg groupid=$groupid --build-arg image_name=$image_name -t $image_name $image_name || exit $?

./build.sh
echo -e "${GREEN}>>> DONE!${NC}"

