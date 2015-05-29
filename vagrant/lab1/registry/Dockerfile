FROM registry.access.redhat.com/rhel:7.1-6
MAINTAINER Student <student@foo.io>

ADD ./local.repo /etc/yum.repos.d/local.repo
ADD ./hosts /new-hosts
RUN cat /new-hosts >> /etc/hosts && yum -y install docker-registry && yum clean all

EXPOSE 5000

ENV DOCKER_REGISTRY_CONFIG /etc/docker-registry.yml
ENV SETTINGS_FLAVOR local
ENV REGISTRY_PORT 5000

WORKDIR /usr/lib/python2.7/site-packages/docker-registry
CMD ["/usr/bin/gunicorn", "--access-logfile", "-", "--debug", "--max-requests", "100", "--graceful-timeout", "3600", "-t", "3600", "-k", "gevent", "-b", "${REGISTRY_ADDRESS}:${REGISTRY_PORT}", "-w", "$GUNICORN_WORKERS", "docker_registry.wsgi:application"]
