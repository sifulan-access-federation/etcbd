#!/bin/bash

# Shell script to run as PID 1 withthe following responsibilities:
# * Launch Icinga (icinga2 daemon -d)
# * Handle signals and pass them to Icinga (INT/TERM/HUP)
# * Invoke cron jobs (fetch configuration and reload Icinga)
#
# Main reason for not using Icinga as PID 1 is that a reload happens through a
# child process and parent process terminates when handing over to child.
# (Child still takes care of reaping the parent).
#
# Expects:
#   CONF_URL_LIST to be set to white-space separated list of URLs to fetch (default: https://SITE_PUBLIC_HOSTNAME/icingaconf).
#   CONF_URL_USER, CONF_URL_PASSWORD (no default)
#   CONF_REFRESH_INTERVAL: period (in seconds) between refreshes (default: 3600s)
#   CONF_TARGET_DIR (default: /etc/icinga2/externalconf)

# initialize variables

if [ -z "$CONF_REFRESH_INTERVAL" ] ; then
    CONF_REFRESH_INTERVAL=3600
fi

if [ -z "$CONF_URL_LIST" ] ; then
    CONF_URL_LIST="https://${SITE_PUBLIC_HOSTNAME}/icingaconf"
fi

if [ -z "$CONF_TARGET_DIR" ] ; then
    CONF_TARGET_DIR="/etc/icinga2/externalconf"
fi

# symlink to current configuration
CONF_CURRENT_DIR="$CONF_TARGET_DIR/current"

# Internal configuration
ICINGA_START_CMD="$*"

if [ -z "$ICINGA_START_CMD" ] ; then
    ICINGA_START_CMD="/usr/sbin/icinga2 daemon -d"
fi
ICINGA_PID_FILE="/var/run/icinga2/icinga2.pid"
EMAIL_PROG="/usr/local/bin/send_notification.py"

# override locale to disable special characters in WGET output
LANG=C

#internal variable
LOOP_RUNNING="yes"

function nudge_icinga() {
    signal=$1
    kill -$signal `cat $ICINGA_PID_FILE`
}

function cleanup() {
    signal=$1
    echo "$0 ending with signal $signal"

    # terminate icinga
    kill -$signal `cat $ICINGA_PID_FILE`

    # terminate the loop and the sleep process
    LOOP_RUNNING=
    if [ -n "$SLEEP_PID" ] ; then
        # sleep needs SIGTERM to be killed
        kill -SIGTERM $SLEEP_PID
    fi
    return
}

# auxilliary functions
# create temp dir and log file - populate DIR, ERR_LOG, IS_ERROR as needed
function setup_temp_dir() {
    ERR_LOG=$( mktemp )
    DIR=$( mktemp -d ${CONF_TARGET_DIR}/conf.XXXXX )
    if [ $? -ne 0 -o -z "$DIR" -o ! -d "$DIR" ] ; then
        IS_ERROR="Could not create temporary directory."
    else
        # make the new directory readable
        chmod a+rx $DIR
    fi
}

# fetch conf files - expect DIR, populate IS_ERROR as needed
function fetch_conf_files() {
    wget -P "$DIR" $WGET_EXTRA_OPTS --user "$CONF_URL_USER" --password "$CONF_URL_PASSWORD" $CONF_URL_LIST 2> $ERR_LOG
    if [ $? -ne 0 ] ; then
       IS_ERROR="Fetching configuration from remote URL failed."
    fi
}

# report error - expect IS_ERROR + other email settings from this container
function report_error() {
    { echo "$IS_ERROR" ; echo ; cat $ERR_LOG ; } | $EMAIL_PROG -s "ERROR: Could not refresh Icinga configuration" $ICINGA_ADMIN_EMAIL
}

# Set up to respond to Docker signals
# HUP should propagate just to Icinga
# INT and TERM should go also to other side processes (our sleep process)

trap "echo SIGHUP ; nudge_icinga SIGHUP" SIGINT
trap "echo SIGINT ; cleanup SIGINT" SIGINT
trap "echo SIGTERM ; cleanup SIGTERM" SIGTERM

# Run the main loop

# create initial configuration
if [ ! -d $CONF_TARGET_DIR ] ; then mkdir $CONF_TARGET_DIR ; fi
if [ ! -d $CONF_CURRENT_DIR ] ; then
    IS_ERROR=""
    setup_temp_dir
    if [ -z "$IS_ERROR" ] ; then
        fetch_conf_files
    fi
    # we want to be conservative - even if fetching failed, create the symlink so that Icinga can start
    if [ -n "$DIR" ] ; then
        ln -snf $DIR $CONF_CURRENT_DIR
    fi

    if [ -n "$IS_ERROR" ] ; then
        report_error
    fi
    # remove error log file
    rm $ERR_LOG
fi

# start Icinga
$ICINGA_START_CMD

while [ -n "$LOOP_RUNNING" ] ; do
    # Start the refresh loop
    echo "Fetching external configuration"

    # Have we hit an error?  So far good...
    IS_ERROR=""
    IS_NO_CHANGE=""

    setup_temp_dir
    if [ -z "$IS_ERROR" ] ; then

        fetch_conf_files
        if [ -z "$IS_ERROR" ] ; then
           # did anything change
           diff -r $CONF_CURRENT_DIR $DIR > /dev/null 2> $ERR_LOG
           DIFF_RES=$?
           if [ $DIFF_RES -eq 0 ] ; then
               IS_NO_CHANGE="No change in Icinga configuration, ignoring and removing new configuration."
           elif [ $DIFF_RES -eq 2 ] ; then
               IS_ERROR="Error comparing old and new configuration."
           fi
        fi
    fi

    # clean up the temporary dir if we have either any errors or there was no change
    if [ -n "$DIR" -a -n "${IS_ERROR}${IS_NO_CHANGE}" ] ; then
           rm -rf "$DIR"
    fi

    # cut over to new dir if ready
    if [ -z "$IS_ERROR" -a -z "$IS_NO_CHANGE" ] ; then
        OLD_DIR=""
        if [ -n "$CONF_CURRENT_DIR" -a -d "$CONF_CURRENT_DIR" -a -h "$CONF_CURRENT_DIR" ] ; then
            OLD_DIR=$( readlink $CONF_CURRENT_DIR )
        fi

        # cut-over symlink
        ln -snf $DIR $CONF_CURRENT_DIR

        #remove old directory
        if [ -n "$OLD_DIR" -a -d "$OLD_DIR" ] ; then
            rm -rf $OLD_DIR
        fi

        # trigger reload
        nudge_icinga SIGHUP
    fi

    if [ -n "$IS_ERROR" ] ; then
        report_error
    fi
    # remove error log file
    rm $ERR_LOG

    # go to sleep until next refresh
    sleep $CONF_REFRESH_INTERVAL &
    SLEEP_PID=$!
    # Only wait for the sleep to complete if we are not shutting down yet
    if [ -n "$LOOP_RUNNING" ] ; then
        wait
    else
        kill $SLEEP_PID
    fi
    SLEEP_PID=""
done

