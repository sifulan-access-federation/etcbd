#!/bin/bash

if [ -n "$LANG" ] ; then
    LNG_COUNTRY=$( echo $LANG | cut -d '.' -f 1 )
    LNG_CTYPE=$( echo $LANG | cut -d '.' -f 2 )
    if [ -n "$LNG_CTYPE" ] ; then
        CHARMAP_ARGS="-f $LNG_CTYPE"
    fi
    localedef -i "$LNG_COUNTRY" -c $CHARMAP_ARGS -A /usr/share/locale/locale.alias $LANG
fi

