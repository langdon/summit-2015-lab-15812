#Containerizing applications, existing and new: Lab Guide

|   | Containerizing applications, existing and new: Information |
|---|---|
| Technology/Product | Red Hat Enterprise Linux & Containers |
| Difficulty |  2 |
| Time  |  120 minutes  |
| Prerequisites  |   |

## Table of Contents

1. **LAB 1** Docker refresh
1. **LAB 2** Analyzing a monolithic application
1. **LAB 3** Deconstructing an application into microservices
1. **LAB 4** Orchestrated deployment of a decomposed application

###In this lab you will...
Containerization has been a hot button topic for quite a while now, with no signs of letting up on the buzz train. However, what is less clear is how one should move an existing application to a containerized model. In this lab, we will take you through the steps that most people go through when attempting to containerize an application. 

We will show you the "end state" but we will also show you the states you (may) pass through when working through the containerization of an application. Why not just jump to the "end state?" Well, because it is often both instructive and acceptable to deploy an "improperly" containerized application. As a result, it is worthwhile to experience the change by doing it, with the support of our instructors.

We will also cover how you might start a containerized application. However, that is the much simpler case, so we will cover it, albeit breifly, after we work through the "existing container" example.

##Before you begin...
We will be providing computers for this lab, to ensure we don't lose time on "setup." However, if you have experience with Vagrant and RHEL Atomic Host, you should be able to follow along pretty easily with your own computer. If you do choose to use your own, please come in to the lab with a vagrant deployed instance of RHEL Atomic Host that has Docker running.


## LAB 1: Docker refresh

In this lab we will explore the docker environment. If you are familiar with docker this may function as a brief refresher. If you are new to docker this will serve as an introduction to docker basics.

Expected completion: 10-20 minutes

* explore environment (OS, basic services, etc.)
* explore logs
* using sytemctl
* using journalctl
* edit docker config to set private registry
* review trivial example Dockerfile
* build an image from Dockerfile
* inspect image
* run image

## LAB 2: Analyzing a monolithic application

In this lab we will create a container image from an existing application. We will build, run and inspect the container. Then we will analyze the services to understand how the various services interact. 

Expected completion: 10-20 minutes

* Review Dockerfile
* run it, confirm connectivity
* docker ps; docker inspect
* docker images
* curl 
* present an architectual graphic (all-in-one)

Question: which example? Wordpress?

## LAB 3: Deconstructing an application into microservices

In this lab you will deconstruct an application into microservices, creating a multi-container application. In this process we explore the challenges of networking, storage and configuration.

Expected completion: 20-30 minutes

present an architectual graphic (deconstructed, microservices)

answer questions about the app (external reference available?):
* what services?
* what ports?
* how to configure params?
* how to provide persistent storage?

### Create images

* Create Dockerfiles
* build, run, test

## LAB 4: Orchestrated deployment of a decomposed application

In this lab we introduce how to orchestrate a multi-container application in Kubernetes.

Expected completion: 40-60 minutes

Question: single host or multi host?

---

## Previously proposed Labs for Reference

### Application as a multi-service container

1. Download binaries and Dockerfiles from http://****
1. Attempt to run the Dockerfile using:
  * docker build -t $USER/multi-service-app -f docker-artifacts/Dockerfile .
  * docker run -it --rm $USER/multi-service-app /bin/bash
1. Fix Dockerfile
  * fix 1 here
  * fix 2 here
  * docker run -it --rm $USER/multi-service-app /bin/bash
1. play around in the container
  * step 1
  * step 2

### Application as single service containers

1. Download binaries and Dockerfiles from http://****
1. Attempt to run the Dockerfile using:
  * cd service1-app
  * docker build -t $USER/service1-app -f docker-artifacts/Dockerfile .
  * cd ..
1. Fix Dockerfile
  * fix 1 here
  * fix 2 here
  * docker run -dt --rm $USER/service1-app --name "service1-app"
1. work on the next service
  * cd service2-app 
  * docker build -t $USER/service2-app -f docker-artifacts/Dockerfile .
  * cd ..
  * docker run -it --rm $USER/service2-app /bin/bash
1. Fix Dockerfile
  * fix 1 here
  * fix 2 here
  * docker run -it --rm --link="service1-app" $USER/service2-app /bin/bash
1. play around in the container
  * step 1
  * step 2

