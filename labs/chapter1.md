## LAB 1: Docker refresh (Scott)

In this lab we will explore the docker environment. If you are familiar with docker this may function as a brief refresher. If you are new to docker this will serve as an introduction to docker basics.  Don't worry, we will progress rapidly.  To get through this lab, we are going to focus on the environment itself as well as walk through some exercises with a couple of Docker images / containers to tell a complete story and point out some things that you might have to consider when containerizing your application.


###Docker and systemd

* Check out the systemd unit file that starts Docker on our host and that it includes 3 EnvironmentFiles.  These files tell Docker how the Docker daemon, storage and networking should be set up and configured.  Take a look at those files too.  Specifically, in the /etc/sysconfig/docker check out the registry settings.  You may find it interesting that you can ADD_REGISTRY and BLOCK_REGISTRY.  Think about the different use cases for that.


```
# cat /usr/lib/systemd/system/docker.service
# cat /etc/sysconfig/docker
# cat /etc/sysconfig/docker-storage
# cat /etc/sysconfig/docker-network
```

* Now start Docker, or make sure that it is started before moving forward.

```
# systemctl status docker
# systemctl start docker
```

###Docker Help

* Now that we see how the Docker startup process works, we should make sure we know how to get help when we need it.  Run the following commands to get familiar with what is included in the Docker package as well as what is provided in the man pages.  Spend some time exploring here, it's helpful.  When you run *docker info* check out the storage configuration.  You will notice that by default it is using *device mapper loopback*.  This can and should be changed to *device mapper direct LVM*.  Performance and stability will be improved.  See the storage section on the [RHEL Atomic Getting Started Guide.](https://access.redhat.com/articles/rhel-atomic-getting-started#storage) 

```
# rpm -ql docker | grep bin
# rpm -qc docker
# rpm -qd docker
# docker --help
# docker run --help
# docker info
```

###Let's explore a Dockerfile

Here we are just going to explore a simple Dockerfile.  The purpose for this is to have a look at some of the basic commands that are used to construct a Docker image.













