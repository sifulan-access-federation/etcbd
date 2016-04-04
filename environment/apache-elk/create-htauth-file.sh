#!/bin/bash

HTAUTH_FILE=/usr/local/apache2/conf/external/users
# use bcrypt (-B); read from stdin (-i)
HTPASSWD_ARGS="-B -i"
if [ ! -e $HTAUTH_FILE ] ; then
  # Create file if not exists (-c)
  HTPASSWD_ARGS="$HTPASSWD_ARGS -c"
fi

if [ -n "$ADMIN_USERNAME" -a -n "$ADMIN_PASSWORD" ] ; then
    htpasswd $HTPASSWD_ARGS $HTAUTH_FILE "$ADMIN_USERNAME" <<-EOF
$ADMIN_PASSWORD
EOF

fi 
