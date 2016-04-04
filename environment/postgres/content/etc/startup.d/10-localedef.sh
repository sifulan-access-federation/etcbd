#!/bin/bash

function create_locale() {
    TGT_LANG="$1"
    LNG_COUNTRY=$( echo "$TGT_LANG" | cut -d '.' -f 1 )
    LNG_CTYPE=$( echo "$TGT_LANG" | cut -d '.' -f 2 )
    if [ -n "$LNG_CTYPE" ] ; then
        CHARMAP_ARGS="-f $LNG_CTYPE"
    fi
    localedef -i "$LNG_COUNTRY" -c $CHARMAP_ARGS -A /usr/share/locale/locale.alias "$TGT_LANG"
}

if [ -n "$LANG" ] ; then
    create_locale "$LANG"
fi

# If the PostgreSQL database was created with a different locale, create these locales too - otherwise, PostgreSQL server would not start.
if [ -f /var/lib/postgresql/data/postgresql.conf ] ; then
    for PG_LANG in $( grep ^lc_ /var/lib/postgresql/data/postgresql.conf | cut -d "'" -f 2 ) ; do
        if [ "$PG_LANG" != "$LANG" ] ; then
          create_locale "$PG_LANG"
        fi
    done
fi
