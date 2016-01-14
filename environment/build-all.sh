#!/bin/bash

# set defaults
TAG=latest
REPOBASE="reannz"
FORCE=""

# parse arguments


while [ $# -gt 0 ] ; do
    if [ "$1" == "--tag" ] ; then
        TAG="$2"
        shift ; shift
    elif [ "$1" == "--repobase" ] ; then
        REPOBASE="$2"
        shift ; shift
    elif [ "$1" == "--force" ] ; then
        FORCE="$1"
        shift
    else
        echo "Invalid argument $1"
        echo "Usage: $0 [--tag tag] [--repobase repobase] [--force]"
        echo "\t--tag tag: set the tag of the container image"
        echo "\t--repobase repobase: set the base name of the repositories to push into"
        echo "\t--force: pass --force to docker tag to overwrite existing images"
    fi
done

# Services we support
SERVICES="admintool elk icinga"
IMAGES_admintool="apache djnro postgres filebeat"
IMAGES_elk="elasticsearch logstash kibana"
IMAGES_icinga="icingaweb icinga postgres-icinga"

#TAG="$(date +'%F')"

for SERVICE in $SERVICES ; do
    # build the images - with a fresh upstream pull
    COMPOSE_FILE=docker-compose-$SERVICE.yml COMPOSE_PROJECT_NAME=$SERVICE docker-compose build --pull
    for IMAGE in $( eval "echo \${IMAGES_${SERVICE}}" ) ; do
        docker tag $FORCE ${SERVICE}_${IMAGE} ${REPOBASE}/${SERVICE}_${IMAGE}:${TAG}
        docker push $REPOBASE/${SERVICE}_${IMAGE}:${TAG}
    done
done


