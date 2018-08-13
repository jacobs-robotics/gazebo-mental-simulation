# Gazebo Mental Simulation Framework
This repository contains a number of scripts and configurations to create and maintain a complete setup of parallelized experiments in the [Gazebo](http://gazebosim.org/) simulation, wrapped in [Docker](https://www.docker.com/) containers.

This Mental Simulation framework is described and used in
```
T. Fromm and A. Birk, Physics-Based Damage-Aware Manipulation Strategy Planning Using Scene Dynamics Anticipation, International Conference on Intelligent Robots and Systems, 2016, https://arxiv.org/abs/1603.00652
```
and

```
T. Doernbach, Self-Supervised Damage-Avoiding Manipulation Strategy Optimization via Mental Simulation, https://arxiv.org/abs/1712.07452
```

## Dependencies
* Intel or Nvidia graphics card (necessary for the Gazebo visualization, AMD cards are yet untested)
* Linux Kernel 3.10+ (e.g. Ubuntu 14.04 LTS)
* Docker ([Installation instructions](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/))

## Installation
This step needs to be run for the initial creation of the Docker containers as well as for cloning and building the ROS workspaces for deploying your custom experimental setup.
1. install Docker as listed above
2. clone this repository branch: `git clone https://github.com/jacobs-robotics/gazebo-mental-simulation.git`
3. setup your environment as described below
4. execute `./create.sh` script which will 
   - install further dependencies
   - create a workspace in `gazebo-mental-simulation/src`
   - download all code and copy it into the workspaces
   - run an initial build of all containers (this may take a while)
   
> In case `create.sh` takes very long to download some packages or repositories, this is typically due to a temporarily slow connection to some of the dependent servers (e.g. where the ROS or Gazebo repositories are hosted) and cannot be sped up. Please be patient since no containers can be used if the script does not complete successfully.
  
## Set up your environment
All settings are stored in the `config/containers.cfg` file where the following options should be set before executing `create.sh`:

### Meta repository
This repository contains your workspace definition in a [.rosinstall](http://docs.ros.org/independent/api/rosinstall/html/rosinstall_file_format.html) file and will be cloned as the first step.
* `meta_package_name`: name of the package containing your `.rosinstall` file
* `meta_package_uri`: Git URI of the meta package
* `meta_package_branch`: branch name to clone
* `meta_package_rosinstall_path`: path of the `.rosinstall` file inside the package

### Experiments repository
A custom repository which contains your experiments.

### Gazebo models repository
A repository containing any custom Gazebo models you require. If this repository if provided, the models herein will be used instead of the default Gazebo models.

### Build parameters
* `num_containers`: number of containers to use in parallel, they will be named `gazebo-mental-simulationN`
* `num_build_jobs`: number of parallel Catkin build jobs to be executed when building the code inside the containers
* `build_meta_package_only`: if set to "true", build only the meta package and its dependencies inside the containers. This is useful if you have big repositories and want to optimize for runtime.

## Container/Code handling  

### Update experimental code
As soon as your experimental code needs to be updated, run `update.sh` which updates the whole workspace in all containers:
```bash
./update.sh
```
If new code has been pulled during the update process, make sure to run `build.sh` like described below to compile all code.

> In case this takes ages, stating a size of several gigabytes in the "Sending build context to Docker daemon" step: Make sure that your workspace subdirectory (`gazebo-mental-simulation`) is not insanely big because this directories have to be tar-ed entirely in this step.
> Especially large bagfiles cause a huge size of this build context, so move them out of the this directory before updating.

### Build experimental code
For building all containers with one command, use
```bash
./build.sh
```
For building only one container, append the respective container name, e.g.
```bash
./build.sh gazebo-mental-simulation1
```

### Cleanup
For deleting all Docker containers to obtain a clean workspace, run
```bash
./clear.sh
```
If you want to additionally remove all Docker images, use
```bash
./clear.sh -i
```

### Start containers
The `start.sh` script boots up all Docker containers (*gazebo_mental_simulation1..N*). Once this script has completed, you can start your experiments.
```bash
./start.sh
```

### Launch console
In order to open a console inside a container, execute `console.sh` followed by the name of the respective container, e.g.
```bash
./console.sh gazebo-mental-simulation1
```

### Gazebo container debugging
In case Gazebo does not show up when starting it inside a container and you use an Nvidia graphics card, it is most likely that your graphics driver needs to be updated because you installed a newer version on the host since building the containers. Do this like so:
```bash
./update_nvidia_driver.sh
```
If this does not help or you don't use Nvidia graphics, check what's going on using:
```bash
docker logs gazebo-mental-simulation1
```
Often it also helps to clear and rebuild the containers and images using
```bash
./clear.sh -i
```

## Running Experiments
Your own experiments can be implemented in the *experiments repository* defined in `config/containers.cfg`. However, we provide an [example experiments package](https://github.com/jacobs-robotics/gazebo-mental-simulation-experiments) with a bunch of scripts to run repetitive experiments. This package is downloaded automatically because it is set as the default experiments repository.
Please refer to https://github.com/jacobs-robotics/gazebo-mental-simulation-experiments on how to run the experiments after building the containers and code as described above.
