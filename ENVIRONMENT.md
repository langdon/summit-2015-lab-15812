
## lab deployment

* DECISION: use local VMs~~? use cloud VMs?~~
* DECISION: ~~use Fedora as the host as Vagrant is unsupported on RHEL?~~
* DECISION: will CDK be available to attendees? **No**
* DECISION: can we give out deveoper-suite subscriptions to attendees? and/or flag them as having access to the CDK? 

## *Items for Images provided for students

* ~~Base Image of Fedora 21~~
* RHELAH with Docker in a VM
* ~~vagrant, vagrant-libvirt, vagrant-registration, vagrant-atomic, ?~~
* **KVM**

## lab content

* DECISION: what application should we use?
* DECISION: ~~multi-service via supervisord? something else?~~
* DECISION: Can we pre-cache at least the base images? **Yes**
* NOTE: would prefer to use the "docker-artifacts" style of Dockerfile content (to not muddy the app)

