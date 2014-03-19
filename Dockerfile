FROM phusion/baseimage:0.9.8

MAINTAINER Meillaud Jean-Christophe (jc.meillaud@gmail.com)

CMD ["/sbin/my_init"]

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

# Launching Jira
WORKDIR /opt/jira-home
RUN rm -f /opt/jira-home/.jira-home.lock
EXPOSE 8080
CMD ["/opt/jira/bin/start-jira.sh", "-fg"]
