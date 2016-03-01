#!/bin/bash

# Hard-coded localedef: el_GR.UTF-8
# DjNRO code-base uses this locale in a few places - better we have it defined on the system
LNG_COUNTRY=el_GR
LNG_CTYPE=UTF-8
CHARMAP_ARGS="-f $LNG_CTYPE"
TARGET_LANG="$LNG_COUNTRY.$LNG_CTYPE"
localedef -i "$LNG_COUNTRY" -c $CHARMAP_ARGS -A /usr/share/locale/locale.alias $TARGET_LANG

