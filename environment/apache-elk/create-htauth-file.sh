#!/bin/bash

HTAUTH_FILE=/usr/local/apache2/conf/external/users
# use bcrypt (-B); read from stdin (-i); create (always) (-c)
HTPASSWD_ARGS="-B -i -c"

if [ -n "$ADMIN_USERNAME" -a -n "$ADMIN_PASSWORD" ] ; then
    htpasswd $HTPASSWD_ARGS $HTAUTH_FILE "$ADMIN_USERNAME" <<-EOF
$ADMIN_PASSWORD
EOF

fi 
