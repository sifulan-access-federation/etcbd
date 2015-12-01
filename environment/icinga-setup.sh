#!/bin/bash

# Ancillary functions: define separate exec functions for Kubernetes and Docker
# Both provide uniform interface:
# exec_func exec-flags container command
# NOTE: exec-flags must be specified even when empty - add extra ""

function kubectl_exec() {
  FLAGS=$1
  shift
  CONTAINER=$1
  shift
  kubectl exec $FLAGS $PODNAME -c $CONTAINER -- "$@"
}
# TODO: kubectl exec ... why do -i exec's hang?
# Wait for fix to kubernetes/kubernetes#13322 to be included in a release


function docker_exec() {
  FLAGS=$1
  shift
  CONTAINER=$1
  shift
  docker exec $FLAGS -- $CONTAINER "$@"
}

# This script supports both Docker-compose and Kubernetes

PODNAME=""

if [ "$1" == "--pod" ] ; then
    shift
    PODNAME="$1"
    shift
    echo "Using Kubernetes pod $PODNAME"
    function exec_func() { kubectl_exec "$@" ; }
else
    echo "No pod name specified, using docker exec"
    function exec_func() { docker_exec "$@" ; }
fi


if [ $# -eq 0 ] ; then
    echo "Usage: $0 [--pod podname] environment_file(s).."
    exit 1
fi
# Load the local deployment environment variables
# (and filtre the syntax to quote the values first)
eval $( cat "$@" | sed 's/=\(.*\)/="\1"/' )



# Create databases in the Icinga Postgres Instance
# Run a command in the Postgres database to create the role and database
# Equivalant to:
#     psql --command="create role $DB_USER with login encrypted password '$DB_PASSWORD' ;"
#     psql --command="create database $DB_NAME with owner $DB_USER encoding 'UTF8';"

# Icinga2 database

exec_func "" $ICINGA_DB_HOST gosu postgres psql --command="create role $ICINGA_DB_USER with login encrypted password '$ICINGA_DB_PASSWORD' ;"
exec_func "" $ICINGA_DB_HOST gosu postgres psql --command="create database $ICINGA_DB_NAME with owner $ICINGA_DB_USER;"

# Populate structure - invoke psql on postgres host directly
{ echo "set role $ICINGA_DB_USER;" ; exec_func "" icinga cat /usr/share/icinga2-ido-pgsql/schema/pgsql.sql ; } | exec_func "-i" $ICINGA_DB_HOST gosu postgres psql icinga

# Icingaweb2 database

exec_func "" $ICINGAWEB2_DB_HOST gosu postgres psql --command="create role $ICINGAWEB2_DB_USER with login encrypted password '$ICINGAWEB2_DB_PASSWORD' ;"
exec_func "" $ICINGAWEB2_DB_HOST gosu postgres psql --command="create database $ICINGAWEB2_DB_NAME with owner $ICINGAWEB2_DB_USER;"

# Populate structure - invoke psql on postgres host directly
{ echo "set role $ICINGAWEB2_DB_USER;" ; exec_func "" icingaweb cat /usr/share/icingaweb2/etc/schema/pgsql.schema.sql ; } | exec_func "-i" $ICINGA_DB_HOST gosu postgres psql icingaweb2

# Create the admin user
ICINGAWEB2_ADMIN_PASSWORD_HASH=$( openssl passwd -1 "$ICINGAWEB2_ADMIN_PASSWORD" )
exec_func "-i" $ICINGAWEB2_DB_HOST gosu postgres psql icingaweb2 <<-EOF
	INSERT INTO icingaweb_user (name, active, password_hash) VALUES ('$ICINGAWEB2_ADMIN_USER', 1, DECODE('$ICINGAWEB2_ADMIN_PASSWORD_HASH', 'escape'));
	INSERT INTO icingaweb_group (name) VALUES ('Administrators');
	INSERT INTO icingaweb_group_membership (group_id, username) VALUES (1, '$ICINGAWEB2_ADMIN_USER');
EOF

