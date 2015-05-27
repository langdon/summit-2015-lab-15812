## LAB 3: Deconstructing an application into microservices (Aaron)

In this lab you will deconstruct an application into microservices, creating a multi-container application. In this process we explore the challenges of networking, storage and configuration.

Expected completion: 20-30 minutes

present an architectual graphic (deconstructed, microservices)

### Decompose the application

Let's enter the container and explore.

```
docker exec -it bigapp /bin/bash
```

#### Services

From the container namespace list the log directories.

```
ls -l /var/log/
```

We see `httpd` and `mariadb`. These are the services that make up the Wordpress application.

#### Ports

We saw in the Dockerfile that port 80 was exposed. This is for the web server. Let's look at the mariadb logs for the port the database uses:

```
grep port /var/log/mariadb/mariadb.log
```

This shows port 3306 is used.

#### Storage

**Web server**

The Wordpress tar file was extracted into `/var/www/html`. List the files.

```
ls -l /var/www/html
```

If these files change and the container dies the changes will be lost. These files should be mounted to persistent storage on the host.

**Database**

Inspect the `mariadb.log` file to discover the database directory.

```
grep databases /var/log/mariadb/mariadb.log
```

The `/var/lib/mysql` should also be mounted to persistent storage on the host.

### Create images

Now we will develop the two images. Using the information above and the Dockerfile from Lab 2 as a guide we will create Dockerfiles for each service. For this lab we have created a directory for each service with the required files for the service.

```
$ ls -lR
```

#### MariaDB Dockerfile

1. Change to the `mariadb` directory. In a text editor create a file named `Dockerfile`.
1. Add a `FROM` line that uses a specific image tag. Also add `MAINTAINER` information.

        FROM registry.access.redhat.com/rhel:7.1-6
        MAINTAINER Student <student@foo.io>

1. Add local files for this lab environment. This is only required for this lab.

        ADD ./local.repo /etc/yum.repos.d/local.repo
        ADD ./hosts /new-hosts

1. Add the required packages. We'll include `yum clean all` at the end to clear the yum cache.

        RUN cat /new-hosts >> /etc/hosts && \
            yum -y install mariadb-server openssl psmisc net-tools hostname && \
            yum clean all

1. Add the dependent scripts and make them executable.

        ADD scripts /scripts
        RUN chmod 755 /scripts/*

1. Add an instruction to expose the database port.

        EXPOSE 3306

1. Add a `VOLUME` instruction for `/var/lib/mysql`.

        VOLUME /var/lib/mysql

1. Add a `LABEL` instruction to prescribe how the image is to be run. This may be used by the `atomic` CLI to run the image reliably.

        LABEL RUN docker run -d --rm -v ${HOME}/mysql:/var/lib/mysql  --name NAME -e DBUSER=${DBUSER} -e DBPASS={$DBPASS} -e DBNAME=${DBNAME} -e NAME=NAME -e IMAGE=IMAGE IMAGE

1. Finish by adding the `CMD` instruction.

        CMD ["/bin/bash", "/scripts/start.sh"]

Save the file and exit the editor.

#### Wordpress Dockerfile


### Build Images and Test

Build the images
```
docker build -t <hostname_lab_dev_vm>/mariadb .
docker build -t <hostname_lab_dev_vm>/wordpress .
```

Test the database image to confirm connectivity.

```
atomic run <hostname_lab_dev_vm>/mariadb
docker logs $(docker ps -ql)
curl http://localhost:3306
```

Test the Wordpress image to confirm connectivity.

```
atomic run <hostname_lab_dev_vm>/wordpress
docker logs $(docker ps -ql)
curl http://localhost
```

### Push the Images to Local Registry
```
docker push <hostname_lab_dev_vm>/mariadb
docker push <hostname_lab_dev_vm>/wordpress
```
