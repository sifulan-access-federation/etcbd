#!/bin/bash

# Shell script to run in a standalone container to trigger refresh of global KML file
# Expects: KML_REFRESH_INTERVAL to set the period (in seconds) in between refreshes

if [ -z "$KML_REFRESH_INTERVAL" ] ; then
    KML_REFRESH_INTERVAL=3600
fi

LOOP_RUNNING="yes"

function cleanup() {
    echo "$0 ending"
    LOOP_RUNNING=
    if [ -n "$SLEEP_PID" ] ; then
        kill $SLEEP_PID
    fi
    return
}

# Set up to respond to Docker signals

trap "echo SIGINT ; cleanup" SIGINT
trap "echo SIGTERM ; cleanup" SIGTERM

# Run the main loop


while [ -n "$LOOP_RUNNING" ] ; do
  echo "Invoking ./manage.py fetch_kml"
  ./manage.py fetch_kml
  sleep $KML_REFRESH_INTERVAL &
  SLEEP_PID=$!
  # Only wait for the sleep to complete if we are not shutting down yet
  if [ -n "$LOOP_RUNNING" ] ; then
      wait
  else
      kill $SLEEP_PID
  fi
  SLEEP_PID=""
done


