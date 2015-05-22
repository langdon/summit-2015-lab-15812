## Lab environment

* VMs
  1. Single RHEL7.1 VM for development
  1. Single Atomic VM for deployment testing
* KVM (no vagrant)
* RHEL7.1 / Atomic
* No CDK
* application: wordpress (all-in-one -> 2 containers)
* Docker images required: rhel7
* RPM content needed (served locally): `httpd php php-mysql php-gd pwgen supervisor bash-completion openssh-server psmisc tar`
* Other content:
  * http://wordpress.org/latest.tar.gz
  * lab manual served as HTML
  * lab manual served as PDF (take-home on thumb drive)
  * tar of other files: wordpress scripts, rpm repo files, Dockerfile(s), etc.
  * Nulecule files for (optional?) Lab 5

## VM configuration
* Running docker and kubernetes environment. Not required: flannel or skydns
* Services: docker, kube-apiserver, kube-scheduler, kube-controller-manager, kubelet, kube-proxy, etcd

## Questions
* RHEL7.1 for dev; Atomic for testing deployment?
* can we give out deveoper-suite subscriptions to attendees? and/or flag them as having access to the CDK? 


