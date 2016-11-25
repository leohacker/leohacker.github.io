---
title: "Essential Docker"
excerpt: Docker的基本概念和使用
date: 2016-11-10 21:30
categories: [DevOps]
published: false
---
{% include toc %}

### Concept
Docker技术的本质是将一个隔离的容器镜像(image)用linux的内核技术运行起来，在linux的机器上构建出一个隔离的运行环境，称为容器(container)。也就是说，镜像是静态的文件系统快照，容器是运行时实例。[Docker Hub](https://hub.docker.com)提供了管理Docker容器镜像的功能，类似于Git仓库的使用方式和概念，可以建立一个镜像的多个版本，版本是用tag来标识的。

### Install
需要安装的Docker是Docker Engine，主要的功能是运行Docker Image。Docker Engine提供Restful API，Docker CLI通过调用这些API提供用户操作的界面。
```
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
```

### Build Docker Image - Dockerfile
```
docker build -t name:tag .
```
Create the dockerfile in the current folder, them build an images with name:tag.

### Docker Hub (Image Management)
```
# tag the image with version.
docker tag image-id user/image-name:tag-version

# login into docker hub.
docker login

# push the local image to docker hub.
docker push user/image-name

# pull the docker image from docker hub.
docker pull training/sinatra

# Run a container, update the software in the container, them commit this image
docker commit -m "Comment"  -a "author" container-id user/image-name:tag

# remove local image
docker rmi -f image-id
```

## Run docker
```
# run ubuntu image with (-i) interactive mode (-t) pseudo tty.
docker run -t -i ubuntu /bin/bash

# run daemonized docker
docker run -d ubuntu /bin/bash -c "while true; do echo hello world; sleep 1; done"

# run daemonied docker for wabapp, -P map all of ports inside the container to host random ports.
docker run -d -P user/webapp python app.py

# map the host post 80 to container port 5000.
docker run -d -p 80:5000 user/webapp python app.py

# check the host mapping for container port
docker port container-name 5000

# name the container
$ docker run -d -P --name web training/webapp python app.py

# check docker container status
docker ps

# check the process output in docker container.
docker logs container-name
# tail -f like
docker logs -f container-name
# check the process status in container.
docker top container-name
# inspect: list all the information of docker container in json format.
docker inspect container-name

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
```
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

### Troubleshooting
https://docs.docker.com/toolbox/faqs/troubleshoot/
