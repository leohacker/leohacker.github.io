---
title: "Essential Docker"
excerpt: Docker的基本概念和使用
date: 2016-11-10 21:30
categories: [DevOps]
published: true
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

# make you run the docker without sudo.
$ sudo groupadd docker
$ sudo usermod -aG docker $USER

# show the info of docker engine.
$ docker info
```

### Image Management
```bash
# login into docker hub.
docker login -u username

# search the images
docker search sinatra

# push the local image to docker hub.
docker push user/image-name

# pull the docker image from docker hub.
docker pull training/sinatra

# Run a container, update the software in the container, them commit this image
docker commit -m "Comment"  -a "author" container-id user/image-name:tag

# tag the image with version.
docker tag image-id user/image-name:tag

# list local images
docker images

# remove local image
docker rmi -f image-id

# show image layers
docker history image:tag
```

## Container Management
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
# kill
docker kill container-name
# remove
docker rm container-name
# remove all containers
docker rm `docker ps -a -q`

# check docker container status
docker ps
# check container size
docker ps -s

# attach to a container
# 如果是bash进程作为 foreground，得到是一个交互式界面。退出bash也就退出container。
# 如果是一个服务进程作为foreground，得到是此服务进程的log输出界面。
docker attach
```

### Info in Container
```bash
# inspect: list all the information of docker container/image in json format.
docker inspect container-name

# check the process output in docker container.
docker logs container-name
# tail -f like
docker logs -f container-name

# show the host mapping for container port
docker port container-name 5000

# check the process status in container.
docker top container-name
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

### Data
Docker的最佳实践推荐在layers中只包含程序，而不是数据。理由很自然，数据是可能变化的，docker作为镜像要被许多项目共享。
同时程序和数据是一体的，没有任何数据处理的程序是没有意义的。那么数据放哪里呢？Layers是只读，不能保持数据，最外层的可写层
不是持久存在的，如果container被删除了，也就不存在了。作为虚拟云技术，container的生命期完全是动态的，所以需要一个外部的
持久层的数据存储位置。

> A data volume is a directory or file in the Docker host’s filesystem that is mounted directly into a container. Data volumes are not controlled by the storage driver. Reads and writes to data volumes bypass the storage driver and operate at native host speeds. You can mount any number of data volumes into a container. Multiple containers can also share one or more data volumes.

```bash
# 指定一个container内部的位置，使用docker分配的一个volumes目录，匿名数据卷。
# /webapp mount point inside the container, you can use inspect to find the location folder on host.
# /var/lib/docker/volumes/437841e70eaf07782366ba554ce7782b5805cf496256220ae3187946a0815639/_data
docker run -d -P --name web -v /webapp training/webapp python app.py
```

```bash
# 指定docker分配和volumes目录名称
docker run -d -P --name web -v webapp_data:/webapp training/web python app.py
```

```json
"Mounts": [
    {
        "Name": "webapp_data",
        "Source": "/var/lib/docker/volumes/webapp_data/_data",
        "Destination": "/webapp",
        "Driver": "local",
        "Mode": "z",
        "RW": true,
        "Propagation": "rprivate"
    }
],
```

```bash
# 指定一个主机上的目录作为volume目录。
# mount a host directory as data volume.  -v host_path:container_path
$ docker run -d -P --name web -v /src/webapp:/webapp training/webapp python app.py
```

本质上，数据卷的记载就是一个mount的过程，容器内部的目录被另外一个目录覆盖，在unmount后，原来的目录又暴露出来，完全和mount的行为一致。
所以-v 参数也可以用来mount文件，不过由于编辑动作可能导致inode变化，而在容器环境下不允许，所以其实不推荐mount需要写的文件。所以基本上
来说，数据卷这个特性目的就是为了加载数据目录。

docker还支持数据卷容器

```
# 创建一个dbstore名字的数据卷容器
$ docker create -v /dbdata --name dbstore training/postgres /bin/true
# db1, db2使用来自dbstore的数据目录/dbdata
$ docker run -d --volumes-from dbstore --name db1 training/postgres
$ docker run -d --volumes-from dbstore --name db2 training/postgres

# 支持volume的链式引用
$ docker run -d --name db3 --volumes-from db1 training/postgres
```

volume和容器不是绑定的，所以删除容器不会删除数据卷。

```
# find dangline volumes
docker volume ls -f dangling=true
docker rm <volume name>

# docker daemon will clean up anonymous volumes when container deleted.
# /foo deleted but not awesome volume.
$ docker run --rm -v /foo -v awesome:/bar busybox top
```

备份和恢复数据卷

```
# 将dbstore中的数据/dbdata备份到/backup/backup.tar，并通过数据卷加载传递到本地目录。
$ docker run --rm --volumes-from dbstore -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /dbdata

# 加载本地目录到容器的backup目录，然后将备份文件恢复到/dbdata目录。
$ docker run -v /dbdata --name dbstore2 ubuntu /bin/bash
$ docker run --rm --volumes-from dbstore2 -v $(pwd):/backup ubuntu bash -c "cd /dbdata && tar xvf /backup/backup.tar --strip 1"
```
