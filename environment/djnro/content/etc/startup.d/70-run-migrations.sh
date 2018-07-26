#!/bin/bash

# Automatically run Django migrations

# Check DB is reachable
ERR_FILE=$( mktemp)
./manage.py inspectdb > $ERR_FILE 2>&1
STATUS=$?

# Special handling: if test failed because of connection refused, wait and try again
if [ $STATUS -ne 0 ] ; then
  if grep '^django.db.utils.OperationalError:.*Connection refused' < $ERR_FILE ; then
      echo "Waiting for PostgreSQL to come up..."
      sleep 20
      ./manage.py inspectdb > $ERR_FILE 2>&1
      STATUS=$?
  fi
fi
rm $ERR_FILE

if [ $STATUS -ne 0 ] ; then
    echo "Database not accessible, skipping migrations"
    exit 0
fi

echo "Applying migrations"

./manage.py migrate

