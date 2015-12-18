
#  eduroam tools container-based deployment #

## Overall considerations

The ancilliary tools package comprises three separate tools:
* admintool
* metrics
* monitoring

Each of the tools is (at the moment) designed to run in an isolated environment - so on a separate docker host.

Please create three separate VMs with Docker, one for each of the tools.

## Preliminaries

Install and configure Docker.  Please follow https://docs.docker.com/engine/installation/

## Basic setup

On each of the VMs, start by cloning the git repository:

    git clone https://github.com/REANNZ/etcbd

# Deploying admintool

Modify the ````localdev_admintool.env```` file with deployment parameters - override at least the following values:

* SITE_PUBLIC_HOSTNAME: the hostname this site will be visible as
* LOGSTASH_HOST: the hostname the metrics tools will be visible as
* ADMIN_EMAIL: where to send notifications
* EMAIL_* settings to match the local environment (server name, port, TLS and authentication settings)
* SERVER_EMAIL: outgoing email address to use in notifications
* ALL PASSWORDS (administrator, db connection and postgres master password)
* GOOGLE_KEY/GOOGLE_SECRET - provide Key + corresponding secret for an API credential (see below on configuring this one)
* Configure other prameters to match the deployment (REALM_*, TIME_ZONE, MAP_CENTER_*)
  * This includes the optional import of existing data (default imports REANNZ data)

This file is used by both the containers to populate runtime configuration and by a one-off script to populate the database.

Use Docker-compose to build and start the containers:

    export COMPOSE_FILE=docker-compose-admintool.yml COMPOSE_PROJECT_NAME=admintool
    docker-compose build && docker-compose up -d

Run the setup script:

    ./admintool-setup.sh localdev_admintool.env

Optional: Install proper SSL certificates into /var/lib/docker/host-volumes/admintool-apache-certs/server.{crt,key}


# Deploying monitoring tools

Modify the ````localdev_icinga.env```` file with deployment parameters - override at least the following values:

* SITE_PUBLIC_HOSTNAME: the hostname this site will be visible as
* ICINGA_ADMIN_EMAIL: where to send notifications
* EMAIL_* settings to match the local environment (server name, port, TLS and authentication settings)
* ALL PASSWORDS (administrator, db connection and postgres master password)

This file is used by both the containers to populate runtime configuration and by a one-off script to populate the database.

Use Docker-compose to build and start the containers:

    export COMPOSE_FILE=docker-compose-icinga.yml COMPOSE_PROJECT_NAME=icinga
    docker-compose build && docker-compose up -d

Run the setup script:

    ./icinga-setup.sh localdev_icinga.env

Optional: Install proper SSL certificates into /var/lib/docker/host-volumes/icinga-apache-certs/server.{crt,key}

# Deploying metrics tools

Use Docker-compose to build and start the containers:

    export COMPOSE_FILE=docker-compose-elk.yml COMPOSE_PROJECT_NAME=elk
    docker-compose build && docker-compose up -d



