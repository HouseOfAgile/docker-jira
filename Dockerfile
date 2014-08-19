FROM phusion/baseimage:0.9.12

MAINTAINER Meillaud Jean-Christophe (jc.meillaud@gmail.com)

RUN apt-get update
RUN apt-get install -q -y git-core

# Install Java 7

RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y software-properties-common
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y python-software-properties
RUN DEBIAN_FRONTEND=noninteractive apt-add-repository ppa:webupd8team/java -y
RUN apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get install oracle-java7-installer -y

RUN mkdir /srv/www

# Install Jira
ADD install-jira.sh /root/
RUN /root/install-jira.sh

## Install SSH for a specific user (thanks to public key)
ADD ./config/id_rsa.pub /tmp/your_key
RUN cat /tmp/your_key >> /root/.ssh/authorized_keys && rm -f /tmp/your_key

# Add private key in order to get access to private repo
ADD ./config/id_rsa /root/.ssh/id_rsa

# Launching Jira
WORKDIR /opt/jira-home
RUN rm -f /opt/jira-home/.jira-home.lock

# Add mysql driver
RUN curl -sSL http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.32.tar.gz -o /tmp/mysql-connector-java.tar.gz
RUN tar xzf /tmp/mysql-connector-java.tar.gz -C /tmp
RUN cp /tmp/mysql-connector-java-5.1.32/mysql-connector-java-5.1.32-bin.jar /opt/jira/lib/

# Add start script in my_init.d of phusion baseimage
RUN mkdir -p /etc/my_init.d
ADD ./start-jira.sh /etc/my_init.d/start-jira.sh

CMD  ["/sbin/my_init"]
