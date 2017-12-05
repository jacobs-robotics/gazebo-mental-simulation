#!/bin/bash
source config/containers.cfg

# check the driver version
NVIDIA_VERSION=""
if [ -d /sys/module/nvidia ]; then
	NVIDIA_VERSION=$(cat /sys/module/nvidia/version)
else
  echo -e "${RED}>>> ERROR: No Nvidia driver found!${NC}" >&2
  exit 1
fi

NO_START_CONTAINERS=0
if [[ ($# -gt 0 && $1 == "-s") ]]; then
    NO_START_CONTAINERS=1
fi

# download the correct driver version
echo -e "${GREEN}>>> Downloading and installing latest Nvidia graphics driver...${NC}"
NVIDIA_DRIVER=/tmp/nvidia/NVIDIA.run
mkdir -p /tmp/nvidia
chown -R $user:$user /tmp/nvidia
curl "http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run" -o $NVIDIA_DRIVER

# reset the flag which marks if the driver has been installed already
rm /tmp/nvidia/NVIDIA.*.installed &>/dev/null

if [[ ("$NO_START_CONTAINERS" -eq "0" ) ]]; then
    ./start.sh
fi

echo -e "${GREEN}>>> DONE!${NC}"
