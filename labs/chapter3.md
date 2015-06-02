## LAB 3: Deconstructing an application into microservices (Aaron)

In this lab you will deconstruct an application into microservices, creating a multi-container application. In this process we explore the challenges of networking, storage and configuration.

Expected completion: 20-30 minutes

TODO: present an architectual graphic (deconstructed, microservices)

### Decompose the application

In the previous lab we created an "all-in-one" application. Let's enter the container and explore.

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

Once we've inspected the container stop and remove it. `docker ps -ql` prints the ID of the latest created container.  First you will need to exit the container.

```
exit
docker stop $(docker ps -ql)
docker rm $(docker ps -ql)
```

### Create the Dockerfiles

Now we will develop the two images. Using the information above and the Dockerfile from Lab 2 as a guide we will create Dockerfiles for each service. For this lab we have created a directory for each service with the required files for the service.  Please explore these directories and check out the contents.

```
cd /root/workspace
cp -R /root/lab3/mariadb .
cp -R /root/lab3/wordpress .
ls -lR mariadb
ls -lR wordpress
```

#### MariaDB Dockerfile

1. In a text editor create a file named `Dockerfile` in the `mariadb` directory.

        vi mariadb/Dockerfile

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

1. Finish by adding the `CMD` instruction.

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

1. Add the required packages. We'll include `yum clean all` at the end to clear the yum cache.

        RUN cat /new-hosts >> /etc/hosts && \
            yum -y install httpd php php-mysql php-gd openssl psmisc tar && \
            yum clean all

1. Add the dependent scripts and make them executable.

        ADD scripts /scripts
        RUN chmod 755 /scripts/*

1. Add the Wordpress source from gzip tar file. Docker will extract the files.

        COPY latest.tar.gz /latest.tar.gz
        RUN tar xvzf /latest.tar.gz -C /var/www/html --strip-components=1
        RUN rm /latest.tar.gz
        RUN chown -R apache:apache /var/www/

1. Add an instruction to expose the web server port.

        EXPOSE 80

1. Add a `VOLUME` instruction for Wordpress uploads.

        VOLUME /var/www/html/wp-content/uploads

1. Finish by adding the `CMD` instruction.

        CMD ["/bin/bash", "/scripts/start.sh"]

Save the Dockerfile and exit the editor.

### Build Images, Test and Push

Now we are ready to build the images to test our Dockerfiles.

1. Build each image. When building an image docker requires the path to the directory of the Dockerfile. 

        docker build -t mariadb mariadb/
        docker build -t wordpress wordpress/

1. If the build does not return `Successfully built <image_id>` the resolve the issue and build again. Once successful, list the images.

        docker images

1. Configure the local directories for persistent storage. We also need to change the SELinux context so the applications have permission to read and write to the directories.

        mkdir -p /var/lib/mariadb
        mkdir -p /var/lib/wp_uploads
        chcon -Rt svirt_sandbox_file_t /var/lib/mariadb
        chcon -Rt svirt_sandbox_file_t /var/lib/wp_uploads

1. Run the database image to confirm connectivity. It takes some time to discover all of the necessary `docker run` options.
  * `-d` to run in daemonized mode
  * `-v <host/path>:<container/path>` to bindmount the directory for persistent storage
  * `-p <host_port>:<container_port>` to map the container port to the host port

            docker run -d -v /var/lib/mariadb:/var/lib/msyql -p 3306:3306 -e DBUSER=user -e DBPASS=mypassword -e DBNAME=mydb --name mariadb mariadb
            docker logs $(docker ps -ql)
            ls -l /var/lib/mariadb
            curl http://localhost:3306

  **Note**: the `curl` command does not return useful information but demonstrates a response on the port.

1. Test the Wordpress image to confirm connectivity. Additional run options:
  * `--link <name>:<alias>` to link to the database container

            docker run -d -v /var/lib/wp_uploads:/var/www/html/wp-content/uploads -p 80:80 --link mariadb:db --name wordpress wordpress
            docker logs $(docker ps -ql)
            ls -l /var/lib/wp_uploads
            curl -L http://localhost

#### The atomic CLI

When we have a working `docker run` recipe add a `LABEL RUN` instruction towards the bottom of each Dockerfile above the CMD to prescribe how the image is to be run. In addition to providing informative human-readable metadata, `LABEL`s may be used by the `atomic` CLI to run an image the way a developer designed it to run. This avoids having to copy+paste from README files. The `atomic` tool is installed on both RHEL and Atomic hosts. It is useful in controlling the Atomic host as well as running containers. The environment variables `NAME` and `IMAGE` are used by atomic CLI to provide metadata in the container.

        LABEL RUN docker run -d -v /var/lib/wp_uploads:/var/www/html/wp-content/uploads -p 80:80 --link=mariadb:db --name NAME -e NAME=NAME -e IMAGE=IMAGE IMAGE

1. Rebuild the Wordpress image. The image cache will be used so only the changes will need to be built.

        docker build -t wordpress wordpress/

1. Re-run the Wordpress image using the `atomic` CLI and test using the methods from the earlier step.

        docker stop wordpress
        docker rm wordpress
        atomic run wordpress

1. Once satisfied with the images tag them with the URI of the local lab local registry

        docker tag mariadb summit-rhel-dev/mariadb
        docker tag wordpress summit-rhel-dev/wordpress
        docker images

1. Push the images

        docker push summit-rhel-dev:5000/mariadb
        docker push summit-rhel-dev:5000/wordpress

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
