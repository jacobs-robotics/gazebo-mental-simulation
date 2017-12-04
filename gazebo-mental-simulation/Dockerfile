FROM ros:indigo-robot-trusty

MAINTAINER Tobias Fromm "t.fromm@jacobs-university.de"

LABEL gazebo-mental-simulation=

ARG user
ARG userid
ARG group
ARG groupid
ARG image_name

# set up users and groups
RUN addgroup -q --gid $groupid $group && \
	adduser -q --uid $userid --gid $groupid --shell /bin/bash $user && \
    mkdir -p /etc/sudoers.d && \
	echo "$user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$user && \
	chmod 0440 /etc/sudoers.d/$user
    
# upgrade existing packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*
    
# install bootstrap tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*

# setup environment
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV ROS_DISTRO indigo

# setup keys
# Ubuntu
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 19274DEF
# ROS
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116
# catkin_tools
RUN wget http://packages.ros.org/ros.key -O - | apt-key add -
# Gazebo
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add -

# setup sources.list
# Ubuntu
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
# Gazebo
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -sc) main" >> /etc/apt/sources.list.d/gazebo-stable.list
# PCL
RUN echo "deb http://ppa.launchpad.net/v-launchpad-jochen-sprickerhof-de/pcl/ubuntu $(lsb_release -sc) main" >> /etc/apt/sources.list
# catkin_tools
RUN /bin/bash -c "echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list"

# install Gazebo
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gazebo7 \
    libgazebo7-dev \
    && rm -rf /var/lib/apt/lists/*
    
# install Gazebo dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ros-indigo-gazebo7-ros \
    ros-indigo-gazebo7-plugins \
    ros-indigo-gazebo7-ros-control \
    ros-indigo-joy \
    ros-indigo-control-toolbox \
    ros-indigo-controller-manager \
    ros-indigo-transmission-interface \
    ros-indigo-joint-limits-interface \
    ros-indigo-joint-state-controller \
    && rm -rf /var/lib/apt/lists/*

# install visualization-related tools
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
	mesa-utils \
	binutils \
	xvfb \
	psmisc \
	libgl1-mesa-glx \
	libgl1-mesa-dri \
	xserver-xorg-video-all \
	&& rm -rf /var/lib/apt/lists/*

# install other packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python-catkin-tools \
    python-pandas \
    python-pip \
    mlocate \
    libpcl-all \
    libopencv-dev \
    libfltk1.3-dev \
    libsuperlu3-dev \
    libbullet-dev \
    libglew-dev \
    libsuitesparse-dev \
    libfl-dev \
    libv4l-dev \
    libeigen2-dev \
    libeigen3-dev \
    libcgal-dev \
    libignition-math2-dev \
    liblog4cpp5-dev \
    ros-indigo-ros-core \
    ros-indigo-ros-base \
    ros-indigo-desktop \
    ros-indigo-pcl-ros \
    ros-indigo-pcl-msgs \
    ros-indigo-pcl-conversions \
    ros-indigo-vision-opencv \
    ros-indigo-gazebo7-ros \
    ros-indigo-gazebo7-plugins \
    ros-indigo-gazebo7-ros-control \
    ros-indigo-control-toolbox \
    ros-indigo-controller-manager \
    ros-indigo-transmission-interface \
    ros-indigo-joint-limits-interface \
    ros-indigo-object-recognition-msgs \
    ros-indigo-ompl \
    ros-indigo-octomap-msgs \
    ros-indigo-tf2-sensor-msgs \
    ros-indigo-move-base-msgs \
    ros-indigo-convex-decomposition \
    ros-indigo-ivcon \
    ros-indigo-robot-model \
    ros-indigo-srdfdom \
    ros-indigo-fcl \
    ros-indigo-shape-tools \
    ros-indigo-ompl \
    ros-indigo-warehouse-ros \
    ros-indigo-manipulation-msgs \
    ros-indigo-pr2-controller-manager \
    ros-indigo-pr2-controllers-msgs \
    ros-indigo-pr2-gripper-action \
    ros-indigo-pr2-head-action \
    ros-indigo-pr2-arm-kinematics \
    ros-indigo-pr2-moveit-* \
    ros-indigo-single-joint-position-action \
    ros-indigo-robot-pose-ekf \
    ros-indigo-nav-pcontroller \
    ros-indigo-image-view \
    ros-indigo-log4cpp \
    ros-indigo-rosjava-build-tools \
    && rm -rf /var/lib/apt/lists/*
        
# install scikit-learn
RUN pip install -U scikit-learn

# prepare directories for Nvidia driver if present
RUN mkdir -p /usr/lib/xorg/modules/drivers /usr/lib/x86_64-linux-gnu/dri && \
	chmod go+x /usr/lib/xorg/modules/drivers /usr/lib/x86_64-linux-gnu/dri && mkdir -p /tmp/nvidia && chown -R $user:$user /tmp/nvidia
    
# prevent from "libGL.so not found" bugs when building OpenGL applications
RUN test -f /usr/lib/x86_64-linux-gnu/libGL.so || ln -s -f -i /usr/lib/libGL.so.1 /usr/lib/x86_64-linux-gnu/libGL.so  
    
# create initial workspace
RUN mkdir -p /home/$user/$image_name/src
RUN mkdir -p /home/$user/.gazebo/models
RUN mkdir -p /home/$user/results
RUN mkdir -p /home/$user/logs
RUN mkdir -p /home/$user/world_files
RUN rm /etc/ros/rosdep/sources.list.d/20-default.list
RUN rosdep init
RUN /bin/bash -c ". /opt/ros/indigo/setup.bash; cd /home/$user/$image_name; catkin init; catkin build"
RUN /bin/bash -c "echo source /home/$user/$image_name/devel/setup.bash >> /home/$user/.bashrc"
RUN /bin/bash -c "chown -R $user:$user /home/$user/"

# TODO this needs to be fixed - start Xvfb to have an X11 terminal open, this allows for GUI applications to run
#CMD /bin/bash -c ". /usr/share/gazebo/setup.sh && rm -f /tmp/.X1-lock && Xvfb :1 -screen 0 1600x1200x16 && tail -f /dev/null"
CMD /bin/bash -c ". /usr/share/gazebo/setup.sh && tail -f /dev/null" 
