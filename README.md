# Nachos
TrustBuilder Training Labs
v2.0 - 2024.03 - BRO

## Prerequisites
You need a working **docker** installation and **docker compose** running on your machine.

## Quick start
Clone the GIT repository and start Labs:

~~~bash
git clone https://github.com/trustbuilder/nachos.git
cd nachos
docker compose up -d
~~~

by default the guacamole frontend will try to authenticate the user with configured extensions and the priority oreder defined by the following line in the *x-config* section :
~~~python
      EXTENSION_PRIORITY: "postgresql,ldap,radius"
~~~

If you wish to control which authentication method is allowed, change this line. For example for only Radius :
~~~python
      EXTENSION_PRIORITY: "radius"
~~~

## Details
To understand some details have a look at parts of the `compose.yml` file:

### Networking
The following part of docker-compose.yml will create a network with name `guacamole_network` in mode `bridged`.
~~~python
...
# networks
# create a network 'guacamole_network' in mode 'bridged'
networks:
  guacamole_network:
    driver: bridge
...
~~~

### Services
#### guacd
The following part of compose.yml will create the guacd service. guacd is the heart of Guacamole which dynamically loads support for remote desktop protocols (called "client plugins") and connects them to remote desktops based on instructions received from the web application. The container will be called `guacd_compose` based on the docker image `guacamole/guacd` connected to our previously created network `guacnetwork_compose`. Additionally we map the 2 local folders `./drive` and `./record` into the container. We can use them later to map user drives and store recordings of sessions.

~~~python
...
services:
#----------------------------------------      
# guacamole daemon (guacd)
#----------------------------------------      
  guacd:
    container_name: guacd
    image: guacamole/guacd:1.5.4
    networks:
      guacamole_network:
    restart: always
...
~~~

#### PostgreSQL
The following part of compose.yml will create an instance of PostgreSQL using the official docker image. This image is highly configurable using environment variables. It will for example initialize a database if an initialization script is found in the folder `/docker-entrypoint-initdb.d` within the image. Since we map the local folder `./init` inside the container as `docker-entrypoint-initdb.d` we can initialize the database for guacamole using our own script (`./init/initdb.sql`). You can read more about the details of the official postgres image [here](http://).

~~~python
...
#----------------------------------------      
# postgres
#----------------------------------------      
  postgres:
    container_name: postgres
    environment:
      TZ: Europe/Paris
      PGDATA: /var/lib/postgresql/data/guacamole
      POSTGRES_DB: guacamole_db
      POSTGRES_PASSWORD: 'ChooseYourOwnPasswordHere1234'
      POSTGRES_USER: guacamole_user
    image: postgres:15.2-alpine
    networks:
      guacamole_network:
    restart: always
    volumes:
    - ./.hide/init:/docker-entrypoint-initdb.d:z
    - ./.hide/data:/var/lib/postgresql/data:Z
    ports:
    - 5432:5432
...
~~~

#### nginx
The following part of docker-compose.yml will create an instance of nginx that maps the public port 8443 to the internal port 443. The internal port 443 is then mapped to guacamole using the `./nginx/templates/guacamole.conf.template` file. The container will use the previously generated (`prepare.sh`) self-signed certificate in `./nginx/ssl/` with `./nginx/ssl/self-ssl.key` and `./nginx/ssl/self.cert`.

~~~python
...
#----------------------------------------      
# nginx
#----------------------------------------      
  nginx:
   container_name: nginx
   restart: always
   image: nginx
   volumes:
   - ./.hide/nginx/templates:/etc/nginx/templates:ro
   - ./.hide/nginx/ssl/self.cert:/etc/nginx/ssl/self.cert:ro
   - ./.hide/nginx/ssl/self-ssl.key:/etc/nginx/ssl/self-ssl.key:ro
   ports:
   - 8443:443
   links:
   - guacamole
   networks:
     guacamole_network:
...
~~~

#### ldap server
The following part of docker-compose.yml will create an instance of an ldap server that maps the public port 389 to the internal port 10389 and the public port 636 (ldaps) to the internal port 10636
This service will start only with the profile option *ldapproxy* :

~~~python
docker compose --profile ldapproxy up -d
~~~

~~~python
...
#----------------------------------------      
# ldap_server
#----------------------------------------      
  ldap_server:
    image: rroemhild/test-openldap
    container_name: ldap_server
    hostname: ldap
    restart: on-failure
    networks:
       guacamole_network:
    labels:
      org.label-schema.group: "ldap-server"
    ports:
      - "389:10389"
      - "636:10636"
    volumes:
      - ./.hide/ldap:/ldap:rw
...
~~~
#### ldap proxy
The following part of docker-compose.yml will create an instance of TrustBuilder ldap proxy that maps the public port 10389 to the internal port 389 and the public port 10636 (ldaps) to the internal port 636
This service will start only with the profile option *ldapproxy* :

~~~python
docker compose --profile ldapproxy up -d
~~~

NB : This service will be build at the first run through the provided *Dockerfile*

~~~python
...
#----------------------------------------      
# ldap_proxy
#----------------------------------------      
  ldap_proxy:
    image: trustbuilder/ldap_proxy:1.6.1
    container_name: ldap_proxy
    hostname: ldapproxy
    # comment next line for NO users authentications in logs
    command: sh -c "cd /ldap-proxy-1.6.1/bin && ./run.sh -verbose"
    environment:
      TZ: Europe/Paris
    build:
      context: .
    networks:
      guacamole_network:
    ports:
      - 10389:389
      - 10636:636
    volumes:
      - ./conf_ldapproxy:/ldap-proxy-1.6.1/config:rw
...
~~~

#### Guacamole
The following part of docker-compose.yml will create an instance of guacamole by using the docker image `guacamole` from docker hub. It is also highly configurable using environment variables.
In this setup it is configured to connect to the previously created postgres instance using a username and password and the database `guacamole_db`. Port 8080 is only exposed locally! An instance of nginx for public facing is the nginx part
In comments you will found settings for Radius, SAML, OIDC and ldap labs
Uncomments the relevant part and provide your settings

~~~python
...
#----------------------------------------      
# guacamole
#----------------------------------------      
  guacamole:
    container_name: guacamole
    image: guacamole/guacamole:1.5.4
    depends_on:
    - guacd
    - postgres
    links:
    - guacd
    networks:
      guacamole_network:
    volumes:
      - ./.hide/guacamole:/guacamolehome:rw
    ports:
    - 8080/tcp
    restart: always 
...
~~~


## prepare.sh
`cd .hide && prepare.sh` is a small script that creates `./init/initdb.sql` by downloading the docker image `guacamole/guacamole` and start it like this:

~~~bash
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgresql > ./init/initdb.sql
~~~

It creates the necessary database initialization file for postgres.

`prepare.sh` also creates the self-signed certificate `./nginx/ssl/self.cert` and the private key `./nginx/ssl/self-ssl.key` which are used
by nginx for https.

You can run it to renew ssh key and initdb which are already included. Use 'reset.sh' before

## reset.sh
To reset everything to the beginning, just run `cd .hide && ./reset.sh`.


**Disclaimer**
This is provided without any warranty. Use it at your own risks