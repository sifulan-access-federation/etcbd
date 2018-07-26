#!/bin/bash

# Use to add tags to latest builds - e.g.:
# ./push-tags.sh reannz/admintool_djnro 1.11 1.11.14

if [ $# -lt 2 ] ; then
    echo "Invalid call $1"
    echo "Usage: $0 source_image destination_tags"
    exit 1
fi

# image
SOURCE_IMAGE=$1
SOURCE_TAG=latest
shift

# push a single repo as one or more target tags

for TAG in "$@" ; do
    docker tag ${SOURCE_IMAGE} ${SOURCE_IMAGE}:${TAG}
    docker push ${SOURCE_IMAGE}:${TAG}
done

