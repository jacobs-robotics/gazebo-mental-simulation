#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
source $parent_path/config/containers.cfg

# check the driver version
NVIDIA_VERSION=""
if [ -d /sys/module/nvidia ]; then
	NVIDIA_VERSION=$(cat /sys/module/nvidia/version)
else
  echo -e "${RED}>>> ERROR: No Nvidia driver found!${NC}" >&2
  exit 1
fi

# download the correct driver version
echo -e "${GREEN}>>> Downloading and installing latest Nvidia graphics driver...${NC}"
NVIDIA_DRIVER=/tmp/nvidia/NVIDIA.run
mkdir -p /tmp/nvidia
chown -R $user:$user /tmp/nvidia
curl "http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run" -o $NVIDIA_DRIVER

# reset the flag which marks if the driver has been installed already
for container in ${containers}
do
    echo -e "${GREEN}>>> Installing Nvidia driver in "$container" container...${NC}"
    docker start ${container} &
	# wait until the container is officially running
	until [ "`/usr/bin/docker inspect -f {{.State.Running}} ${container}`" == "true" ]; do
		sleep 0.1;
	done;
    docker exec -it --user="root" ${container} /bin/bash -c "if test -f /tmp/nvidia/NVIDIA.run; then chmod +x /tmp/nvidia/NVIDIA.run && ( /bin/sh /tmp/nvidia/NVIDIA.run -s --no-kernel-module ) && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -fy; fi";
done

echo -e "${GREEN}>>> DONE!${NC}"
