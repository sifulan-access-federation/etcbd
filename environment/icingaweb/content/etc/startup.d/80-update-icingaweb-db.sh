#!/bin/bash

# setup DB connection

export PGPASSWORD="$ICINGAWEB2_DB_PASSWORD"
export PSQL="psql -U $ICINGAWEB2_DB_USER -d $ICINGAWEB2_DB_NAME -h $ICINGAWEB2_DB_HOST"

# Contrary to Icinga2, in Icingaweb2, there is no version on the database - so we have to do an explicit check if version is needed.
# And there is a single update file to add
SQL_UPDATE="/usr/share/icingaweb2/etc/schema/pgsql-upgrades/2.5.0.sql"

# This file changes the user name field length from 64 to 254 - so check if it has been applied
if $PSQL -t -c '\d icingaweb_user' | grep '^ name ' | cut -d '|' -f 2 | grep -q 'character varying(254)' ; then
    echo "$SQL_UPDATE has already been applied, skipping"
else
    echo "Applying $SQL_UPDATE"
    $PSQL < $SQL_UPDATE
fi

