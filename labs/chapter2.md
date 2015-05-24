## LAB 2: Analyzing a Monolithic Application (Dusty)

In this lab we will create a monolithic container image comprised of
several different applications. We will also observe several bad
practices when composing Dockerfiles and explore how to avoid those
mistakes.

Expected completion: 20 minutes

* overview of monolithic application
* build docker image
* run container based on docker image
* connecting to the application
* review Dockerfile practices

### Monolithic Application Overview and Dockerfile review

Our monolithic application we are going to use in this lab is a simple
wordpress application. Rather than decompose the application into
multiple parts we have elected to put the database and the wordpress
application into the same container. Our container image will have:

* mariadb and all dependencies
* wordpress and all dependencies

To perform some generic configuration of mariadb and wordpress there
are startup configuration scripts that are executed each time a
container is started from the image. These scripts configure the
services and then start them in the running container.

### Building the Docker Image

To build the docker image for this lab please execute the following
commands:

```
cd bigapp/
docker build -t monolithic .
```

### Run Container Based on Docker Image

To run the docker container based on the image we just built use the
following command:

```
docker run -p 80 --name=bigapp -e DBUSER=user -e DBPASS=mypassword -e DBNAME=mydb -d monolithic
```

### Connecting to the Application

First detect the port number that is mapped to the container's port 80:

```
docker port bigapp
```

Now connect to the port via the web browswer on your machine using **http://ip:port**


### Review Dockerfile practices

So we have built a monolithic application using a somewhat complicated
Dockerfile. There are a few principles that are good to follow when creating 
a Dockerfile that we did not follow for this monolithic app:

* Be specific about source image
  * Updates could break things
* Place rarely changing statements towards the top of the file
  * This allows the re-use of cached images when rebuilding
* Group statements with same goal into multiline statements
  * Can help avoid layers that have files needed only for build

To illustrate some problem points in our Dockerfile it has been 
replicated below with some commentary added:

```
FROM registry.access.redhat.com/rhel  

>>> No tags on image specification - updates could break things

MAINTAINER Student <student@foo.io>

# ADD set up scripts
ADD  scripts /scripts

>>> If a local script changes then we have to rebuild from scratch

RUN chmod 755 /scripts/*

# Add in custom yum repository and update
ADD ./local.repo /etc/yum.repos.d/local.repo
ADD ./hosts /new-hosts
RUN cat /new-hosts >> /etc/hosts && yum -y update

>>> Running a yum clean all in the same statement would mean that we
>>> wouldn't have junk in our intermediate cached image

# Common Deps
RUN cat /new-hosts >> /etc/hosts && yum -y install openssl
RUN cat /new-hosts >> /etc/hosts && yum -y install psmisc 

# Deps for wordpress
RUN cat /new-hosts >> /etc/hosts && yum -y install httpd 
RUN cat /new-hosts >> /etc/hosts && yum -y install php 
RUN cat /new-hosts >> /etc/hosts && yum -y install php-mysql 
RUN cat /new-hosts >> /etc/hosts && yum -y install php-gd
RUN cat /new-hosts >> /etc/hosts && yum -y install tar

# Deps for mariadb
RUN cat /new-hosts >> /etc/hosts && yum -y install mariadb-server 
RUN cat /new-hosts >> /etc/hosts && yum -y install net-tools
RUN cat /new-hosts >> /etc/hosts && yum -y install hostname

>>> Can group all of the above into one yum statement to minimize 
>>> intermediate layers.

# Add in wordpress sources 
COPY latest.tar.gz /latest.tar.gz
RUN tar xvzf /latest.tar.gz -C /var/www/html --strip-components=1 
RUN rm /latest.tar.gz
RUN chown -R apache:apache /var/www/

>>> Can group above statements into one multiline statement to minimize 
>>> space used by intermediate layers. (i.e. latest.tar.gz would not be 
>>> stored in any image).

EXPOSE 80
CMD ["/bin/bash", "/scripts/start.sh"]
```
