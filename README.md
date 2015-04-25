docker-jira
===========

Simple Docker container for Atlassian JIRA based on phusions ubuntu base-image (include mysql jar connector)

## Build Docker JIRA instance

    sudo docker build -t="houseofagile/docker-jira" .
 
## Run your JIRA docker instance
 
    sudo docker run -d --name docker-jira -P houseofagile/docker-jira
    

## Add a vhost on your docker root host

The JIRA docker instance should run smoothly in the background, thanks to phusion baseimage, you should be able to connect to it through ssh. depending on your ssh settings, you either connect with the insecure ssh key or with your personal key (which we recommand).

### Find the IP of your docker jira container

Use either docker ps or [some useful script](https://gist.github.com/jmeyo/fface4f606ae6bf5365c)

```
user@someserver:~$ do_get_ip_address 
63d0c34992e4    houseofagile/docker-jira:latest 172.17.0.122
de06f34dcf38    beaudev/mysql:latest    172.17.0.124
347ad346baa3    beaudev/docker-nginx:latest     172.17.0.101
f3d8d346264c    beaudev/scripter:latest 172.17.0.19
e27873454be2    mypostgre/postgresql:latest     172.17.0.88
cf99a3496f47    docker-wordpress-nginx-fr:latest        172.17.0.89
```
### Add a nginx vhost proxy
Once again, thanks to some [useful nginx proxy creation script](https://gist.github.com/jmeyo/0c241bbdc3c1c4df57bf), you can add a vhost to your container easily.

```
user@someserver:~$ do_nginx_proxy_vhost jira.somedomainname.com http://172.17.0.122:8080
Updating proxy for host: jira.somedomainname.com
Restarting nginx: nginx.

```

## Using latest version of JIRA

We are big fans of JIRA, but indeed, that tool could become a bit expensive, thus we are stuck to version 6.4, but you can easily switch to latest version by changing the JIRA version in `install-jira.sh` (last tested with [latest released version 6.3.3](https://confluence.atlassian.com/display/JIRA/JIRA+Release+Summary)).
