---
title: "Essential Docker"
excerpt: Docker的基本概念和使用
date: 2016-11-10 21:30
categories: [DevOps]
published: false
---
{% include toc %}

### Introduction
Docker技术提供了操作系统层面的虚拟化技术，利用Linux内核的cgroups和kernel namespaces，还有Union特性的文件系统，在Linux主机上构建出一个隔离的运行实例，称为容器(container)。镜像是容器运行前的文件系统快照，容器是运行时实例。在Docker的官方网页[镜像，容器和存储器驱动器](https://docs.docker.com/engine/userguide/storagedriver/imagesandcontainers/)介绍了image和其中的多层layer的概念，layer是只读的文件系统，运行时的容器有一个可写层，基于copy on write策略。Layer是在所有镜像之间可以共享的，所以任何一个docker镜像可能很小。如果多个镜像是基于某一个基础镜像做出来的，基础的部分只需要下载一次，效率非常高。

> The Linux kernel's support for namespaces mostly[9] isolates an application's view of the operating environment, including process trees, network, user IDs and mounted file systems, while the kernel's cgroups provide resource limiting, including the CPU, memory, block I/O and network. Since version 0.9, Docker includes the libcontainer library as its own way to directly use virtualization facilities provided by the Linux kernel, in addition to using abstracted virtualization interfaces via libvirt, LXC (Linux Containers) and systemd-nspawn.[10][11][12]    -- from Wikipedia

类似Github, [Docker Hub](https://hub.docker.com)提供了管理Docker容器镜像的功能，类似于Git仓库的使用方式和概念，可以建立一个镜像的多个版本，版本是用tag来标识的。

### Install
需要安装的Docker是Docker Engine，主要的功能是运行Docker Image。Docker Engine提供Restful API，Docker CLI通过调用这些API提供用户操作的界面。
```bash
$ sudo apt-get update
$ sudo apt-get install apt-transport-https ca-certificates

# use the server in ubuntu. the server mentioned in official doc is too busy to response.
$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

#
$ echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
$ sudo apt-get update

$ sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
$ sudo apt-get install docker-engine

$ sudo service docker start
$ sudo systemctl enable docker

# show the info of docker engine.
docker info
```

### Docker Image Management
```bash
# login into docker hub.
docker login

# search the images
docker search sinatra

# push the local image to docker hub.
docker push user/image-name

# pull the docker image from docker hub.
docker pull training/sinatra

# Run a container, update the software in the container, them commit this image
docker commit -m "Comment"  -a "author" container-id user/image-name:tag

# tag the image with version.
docker tag image-id user/image-name:tag-version

# list local images
docker images

# remove local image
docker rmi -f image-id

# show image layers
docer history image:tag
```

## Run docker
```bash
# run ubuntu image with interactive mode(-i) pseudo tty(-t).
docker run -t -i ubuntu /bin/bash

# run daemonized docker
docker run -d ubuntu /bin/bash -c "while true; do echo hello world; sleep 1; done"

# run daemonied docker for wabapp, -P map all of ports inside the container to host random ports.
docker run -d -P user/webapp python app.py

# specify the mapping of host post 80 to container port 5000.
docker run -d -p 80:5000 user/webapp python app.py

# name the container
$ docker run -d -P --name web training/webapp python app.py

# start the container
docker start container-name
# stop the container
docker stop container-name
# restart
docker restart container-name
# remove
docker rm container-name
```

### Network
```bash
# list all the networks (default: null, host, bridge)
$ docker network ls

# show the info of network 'bridge'
$ docker network inspect bridge

# disconnect the container 'networktest' from network 'bridge'
$ docker network disconnect bridge networktest

# create own network, -d specify the driver type.
$ docker network create -d bridge my-bridge-network

# run the container and add to network.
$ docker run -d --network=my-bridge-network --name db training/postgres

# run the interactive shell for container db.
$ docker exec -it db bash
```

### Info of Container
```bash
# show the host mapping for container port
docker port container-name 5000

# check docker container status
docker ps

# check container size
docker ps -s

# inspect: list all the information of docker container in json format.
docker inspect container-name
```

### Info in Container
```bash
# check the process output in docker container.
docker logs container-name

# tail -f like
docker logs -f container-name

# check the process status in container.
docker top container-name
```

### Build Docker Image - Dockerfile
```
docker build -t name:tag .
```
Create the dockerfile in the current folder, them build an images with name:tag.


### Data volume
A data volume is a directory or file in the Docker host’s filesystem that is mounted directly into a container. Data volumes are not controlled by the storage driver. Reads and writes to data volumes bypass the storage driver and operate at native host speeds. You can mount any number of data volumes into a container. Multiple containers can also share one or more data volumes.

### Troubleshooting
https://docs.docker.com/toolbox/faqs/troubleshoot/
