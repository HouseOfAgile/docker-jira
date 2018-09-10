docker-jira
===========

Simple Docker container for Atlassian JIRA based on phusions ubuntu base-image (include mysql jar connector)

## Build Docker JIRA instance

In order to connect with ssh, you should add your ssh keys in a ```config/``` directory. Then you can build it.

    docker build -t="houseofagile/docker-jira" .

## Run your JIRA docker instance

    docker run -d --name docker-jira -P houseofagile/docker-jira

It could be nice to link jira with your mysql instance and to mount your jira-home as a volume

    hoa_instance=jira-prod-staropramen && docker run -d -h $hoa_instance --name $hoa_instance --link staropramen-mysql:heypet-mysql -v /srv/volumes/jira-prod:/opt/jira-home houseofagile/docker-jira


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

## Access your JIRA install
### Simple nginx vhost proxy
Once again, thanks to some [useful nginx proxy creation script](https://gist.github.com/jmeyo/0c241bbdc3c1c4df57bf), you can add a vhost to your container easily.

```
user@someserver:~$ do_nginx_proxy_vhost jira.somedomainname.com http://172.17.0.122:8080
Updating proxy for host: jira.somedomainname.com
Restarting nginx: nginx.

```
### Use it with [jwilder nginx proxy](https://github.com/jwilder/nginx-proxy)

    PROJECT_NAME=”hoa-jira-prod”
    DOMAIN_NAMES=”jira.somedomainname.com”

    docker run -e VIRTUAL_HOST="$DOMAIN_NAMES" -e LETSENCRYPT_HOST="$DOMAIN_NAMES" -e LETSENCRYPT_EMAIL="jc@houseofagile.com" -h $PROJECT_NAME   -v /srv/volumes/jira-prod:/opt/jira-home --name $PROJECT_NAME -d -P houseofagile/docker-jira

### Use it with [traefik](https://github.com/containous/traefik)

Find the private IP of your docker instance (for example 172.17.0.4 here) and configure your toml file.

    # example configuration
    [backends]
    [backends.jira]
    [backends.jira.servers.server1]
    url = "http://172.17.0.4:8080"

    [frontends]

    [frontends.jira]
    backend = "jira"
    passHostHeader = true
    [frontends.jira.routes.main]
    rule = "Host: jira-new.somedomainname.com, jira.somedomainname.com"


## Upgrading to latest version of JIRA

Recommended way could be to deploy it into another subdomain, work on the [migration](https://confluence.atlassian.com/adminjiraserver073/migrating-jira-applications-to-another-server-861253107.html) and switch it to your production version. Stopping production version first is recommended so that your user do not update the db.

Small summary guidelines:

 1. backup system with your current production server and stop current production server
 2. build new version and configure access to a new temp domain
 3. run your new docker instance without jira-home volume and do a fresh install with your new temp domain
 4. stop your new docker instance and mount it with your jira-home directory mounted as a volume
 5. start new docker instance and restore system with your backup
 6. your new jira server should be now running the new version of JIRA
 7. stop your new jira server, switch jira site url from your temp domain to your prod domain and restart your new jira server.

## Troubleshooting

### Enable SSL for JIRA
Using jira in a docker behind a proxy with ssl support could be painful, in a classic traefik environment, your https traffic is also sent to your backend, but then JIRA could be lost.
First switch your jira site scheme in the jira system to https and then edit /opt/jira/conf/server.xml.


    [...]
    <Service name="Catalina">

        <Connector port="8080"

                   maxThreads="150"
                   minSpareThreads="25"
                   connectionTimeout="20000"

                   <!-- Add those 3 lines with your jira domain name -->
                   scheme="https"
                   proxyName="jira.somedomain.com"
                   proxyPort="443"
                   <!-- end -->

                   enableLookups="false"
                   maxHttpHeaderSize="8192"
                   protocol="HTTP/1.1"
                   useBodyEncodingForURI="true"
                   redirectPort="8443"
                   acceptCount="100"
                   disableUploadTimeout="true"
                   bindOnInit="false"/>
    [...]
