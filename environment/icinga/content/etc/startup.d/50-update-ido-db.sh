#!/bin/bash

# setup DB connection

export PGPASSWORD="$ICINGA_DB_PASSWORD"
export PSQL="psql -U $ICINGA_DB_USER -d $ICINGA_DB_NAME -h $ICINGA_DB_HOST"

echo "Checking current iDo DB version..."

IDO_DB_VERSION="$( $PSQL -t -c 'select version from icinga_dbversion;' | tr -d ' ' )"

echo "Found version $IDO_DB_VERSION"

echo "Checking for upgrades"

CURRENT_VERSION_FILE=""
for FILE in /usr/share/icinga2-ido-pgsql/schema/upgrade/*.sql ; do
    if [ -z "$CURRENT_VERSION_FILE" ] ; then
       if grep -q "^SELECT updatedbversion('$IDO_DB_VERSION');$" $FILE ; then
           echo "Skipping current $FILE"
           CURRENT_VERSION_FILE=$FILE
       else
           echo "Skipping past $FILE"
       fi
    else
        echo "Applying $FILE"
        $PSQL < $FILE
    fi
done

echo "Done upgrading."

NEW_IDO_DB_VERSION="$( $PSQL -t -c 'select version from icinga_dbversion;' | tr -d ' ' )"
echo "Found version $NEW_IDO_DB_VERSION"
