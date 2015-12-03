#!/bin/bash

# Read environment variables (and export them) if ENVVARS_FILE points to a readable envvars file:
if [ -n "$ENVVARS_FILE" -a -r "$ENVVARS_FILE" ] ; then
    eval $( cat $ENVVARS_FILE | sed 's/^\([A-Za-z0-9_]*\)=\(.*\)/\1="\2" ; export \1/' )
fi

# Execute the target
exec "$@"

