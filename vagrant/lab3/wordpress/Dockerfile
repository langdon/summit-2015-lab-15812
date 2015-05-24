FROM registry.access.redhat.com/rhel:7.1-6 
MAINTAINER Student <student@foo.io>

# Add in custom yum repository and update
ADD ./local.repo /etc/yum.repos.d/local.repo
ADD ./hosts /new-hosts
RUN cat /new-hosts >> /etc/hosts && yum -y update && yum clean all

# Deps for wordpress
RUN cat /new-hosts >> /etc/hosts && \
    yum -y install httpd php php-mysql php-gd openssl psmisc tar && \
    yum clean all

# Add in wordpress sources
COPY latest.tar.gz /latest.tar.gz
RUN tar xvzf /latest.tar.gz -C /var/www/html --strip-components=1 && \
    rm /latest.tar.gz && \
    chown -R apache:apache /var/www/

# ADD set up scripts
ADD scripts /scripts 
RUN chmod 755 /scripts/*

EXPOSE 80
CMD ["/bin/bash", "/scripts/start.sh"]
