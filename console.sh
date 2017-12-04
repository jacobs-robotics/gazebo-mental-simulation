#!/bin/bash
# open a console for the specified workspace
source config/containers.cfg

if [ "$#" -eq "0" ]; then
  echo -e "${RED}>>> ERROR: Please specify a workspace for which a console shall be opened!${NC}" >&2
  exit 1
fi

docker exec -it --user="${user}" ${1} /bin/bash -c ". /home/${user}/${image_name}/devel/setup.bash && /bin/bash"
