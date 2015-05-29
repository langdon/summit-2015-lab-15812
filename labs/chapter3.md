# SO... i made some edits to content, also asked some questions in this very annoying, but, easily removable, way :)

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

If these files change and the container is removed the changes will be lost. These files should be mounted to persistent storage on the host.

**Database**

Inspect the `mariadb.log` file to discover the database directory.

```
grep databases /var/log/mariadb/mariadb.log
```

The `/var/lib/mysql` should also be mounted to persistent storage on the host.

Once we've inspected the container stop and remove it. `docker ps -ql` prints the ID of the latest created container.

```
docker stop $(docker ps -ql)
docker rm $(docker ps -ql)
```
**Don't** forget to leave the container first.

### Create the Dockerfiles

Now we will develop the two images, one for the database and one for the webserver. Using the information above and the Dockerfile from Lab 2 as a guide, we will create Dockerfiles for each image/container. For this lab we have created a directory for each image with the appropriate files.

```
$ ls -lR
```
# transition problem here, we need to move them to the appropriate directory, or, even, after the above, a blank dir to start this lab.. see also https://github.com/whitel/summit-2015-lab-15812/issues/33
# my comments from here will be based on "blank dir"

#### MariaDB Dockerfile

1. In a text editor create a file named `Dockerfile` in the `mariadb` directory.

        vi mariadb/Dockerfile

1. Add a `FROM` line that uses a specific image tag. Also add `MAINTAINER` information.

        FROM registry.access.redhat.com/rhel:7.1-6
        MAINTAINER Student <student@foo.io>

1. Add local files for this lab environment. This is only required for this lab.

        ADD ./local.repo /etc/yum.repos.d/local.repo
        ADD ./hosts /new-hosts

#cp ~/sync/lab3/mariadb/local.repo ~/my-lab3/mariadb
#cp ~/sync/lab3/mariadb/hosts ~/my-lab3/mariadb

1. Add the required packages. We'll include `yum clean all` at the end to clear the yum cache and save space in the final image size.

        RUN cat /new-hosts >> /etc/hosts && \
            yum -y install mariadb-server openssl psmisc net-tools hostname && \
            yum clean all

1. Add the dependent scripts and make them executable.

        ADD scripts /scripts
        RUN chmod 755 /scripts/*

# cp -R ~/sync/lab3/mariadb/scripts/ ~/my-lab3/mariadb/

1. Add an instruction to expose the database port.

        EXPOSE 3306

1. Add a `VOLUME` instruction for `/var/lib/mysql` which is where we discovered mariadb was storing its data.

        VOLUME /var/lib/mysql

1. Finish by adding the `CMD` instruction. The `CMD` is what will be run if we `docker run` an image passing no arguments at the end.

        CMD ["/bin/bash", "/scripts/start.sh"]

Save the file and exit the editor.

#### Wordpress Dockerfile

Now we'll create the Wordpress Dockerfile.

1. Using a text editor create a file named `Dockerfile` in the `wordpress` directory.

        vi wordpress/Dockerfile

1. Add a `FROM` line that uses a specific image tag. Also add `MAINTAINER` information.

        FROM registry.access.redhat.com/rhel:7.1-6
        MAINTAINER Student <student@foo.io>

1. Add local files for this lab environment. This is only required for this lab.

        ADD ./local.repo /etc/yum.repos.d/local.repo
        ADD ./hosts /new-hosts
#cp ~/sync/lab3/wordpress/hosts ~/my-lab3/wordpress/
#cp ~/sync/lab3/wordpress/local.repo ~/my-lab3/wordpress/

1. Add the required packages. We'll include `yum clean all` at the end to clear the yum cache.

        RUN cat /new-hosts >> /etc/hosts && \
            yum -y install httpd php php-mysql php-gd openssl psmisc tar && \
            yum clean all

1. Add the dependent scripts and make them executable.

        ADD scripts /scripts
        RUN chmod 755 /scripts/*

#cp -R ~/sync/lab3/wordpress/scripts/ ~/my-lab3/wordpress/

1. Add the Wordpress source from gzip tar file. Docker will extract the files and remove the tar.

        ADD latest.tar.gz /var/www/html
        RUN chown -R apache:apache /var/www/

#  cp ~/sync/lab3/wordpress/latest.tar.gz ~/my-lab3/wordpress/

1. Add an instruction to expose the web server port.

        EXPOSE 80

1. Add a `VOLUME` instruction for `/var/www/html` so that we won't lose the web files if the container is removed.

        VOLUME /var/www/html

1. Finish by adding the `CMD` instruction.

        CMD ["/bin/bash", "/scripts/start.sh"]

Save the Dockerfile and exit the editor.

### Build Images, Test and Push

Now we are ready to build the images to test our Dockerfiles.

1. Build each image. When building an image docker requires the path to the directory of the Dockerfile.

        docker build -t mariadb mariadb/
        docker build -t wordpress wordpress/

1. If the build does not return `Successfully built <image_id>` resolve the issue and build again. Once successful, list the images.

        docker images

1. Run the database image to confirm connectivity. It takes some time to discover all of the necessary `docker run` options.
  * `-d` to run in daemonized mode
  * `-v <host/path>:<container/path>` to bindmount the directory for persistent storage
  * `-p <host_port>:<container_port>` to map the container port to the host port

            docker run -d -p 3306:3306 -e DBUSER=user -e DBPASS=mypassword -e DBNAME=mydb --name mariadb mariadb
            docker logs $(docker ps -ql)
            curl http://localhost:3306

  **Note**: the `curl` command does not return useful information but demonstrates an appropriate response on the port.

#should we kill the maria instance before moving on?

1. Test the Wordpress image to confirm connectivity. Additional run options:
  * `--link <name>:<alias>` to link to the database container

            docker run -d -p 80:80 --link mariadb:db wordpress
            docker logs $(docker ps -ql)
            curl http://localhost

1. When we have a working `docker run` recipe add a `LABEL RUN` instruction to each Dockerfile to prescribe how the image is to be run. This instruction will be used by the `atomic` CLI to run the image reliably. The environment variables `NAME` and `IMAGE` are used by atomic CLI
  * MariaDB

            LABEL RUN docker run -d -v ${HOME}/mysql:/var/lib/mysql  --name NAME -e DBUSER=${DBUSER} -e DBPASS={$DBPASS} -e DBNAME=${DBNAME} -e NAME=NAME -e IMAGE=IMAGE IMAGE

  * Wordpress

            LABEL RUN docker run -d -v ${HOME}/wordpress:/var/www/html -p 80:80 --link=mariadb:db --name NAME -e NAME=NAME -e IMAGE=IMAGE IMAGE

1. Rebuild the images. The image cache will be used so only the changes will need to be built.

        docker build -t mariadb mariadb/
        docker build -t wordpress wordpress/

1. Run the images using the `atomic` CLI and test using the methods from step 4.

        atomic run mariadb
        atomic run wordpress

# no atomic in the image.. adding to vagrantfile

# should we test that they can talk to each other with docker-link?

1. Once satisfied with the images tag them with the URI of the local lab local registry

        docker tag mariadb <hostname_lab_dev_vm>/mariadb
        docker tag wordpress <hostname_lab_dev_vm>/wordpress
        docker images

1. Push the images

        docker push <hostname_lab_dev_vm>/mariadb
        docker push <hostname_lab_dev_vm>/wordpress

# want to show how to add "--insecure-registry"? i know i found the "hints" in the config file confusing
# i think you need to specify the port unless the registry is running on 80

### Clean Up

Stop the mariadb and wordpress containers.

```
docker ps
docker stop <wp_container_id> <db_container_id>
```

After iterating through running docker images you will likely end up with many stopped containers. List them.

```
docker ps -a
```

This command is useful in freeing up disk space by removing all stopped containers.

```
docker rm $(docker ps -qa)
```
