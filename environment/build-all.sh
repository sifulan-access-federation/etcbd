#!/bin/bash

# set defaults
TAG=latest
REPOBASE="reannz"
FORCE=""
PULL=""
NOCACHE=""
SKIPBUILD=""

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
    elif [ "$1" == "--pull" ] ; then
        PULL="$1"
        shift
    elif [ "$1" == "--no-cache" ] ; then
        NOCACHE="$1"
        shift
    elif [ "$1" == "--skip-build" ] ; then
        SKIPBUILD="$1"
        shift
    else
        echo "Invalid argument $1"
        echo "Usage: $0 [--tag tag] [--repobase repobase] [--force]"
        echo "    --tag tag: set the tag of the container image"
        echo "    --repobase repobase: set the base name of the repositories to push into"
        echo "    --force: pass --force to docker tag to overwrite existing images"
        echo "    --pull: pass --pull to docker-compose build to refresh base images"
        echo "    --no-cache: pass --no-cache to docker-compose build to do a fresh build"
        echo "    --skip-build: skip docker-compose build - only tag and push current build"
        exit 1
    fi
done

# Services we support
SERVICES="admintool elk icinga"
IMAGES_admintool="apache djnro postgres filebeat"
IMAGES_elk="elasticsearch logstash kibana"
IMAGES_icinga="icingaweb icinga postgres-icinga"
EXTRA_IMAGES="filebeat-radius"

#TAG="$(date +'%F')"

for SERVICE in $SERVICES ; do
    # build the images
    if [ -z "$SKIPBUILD" ] ; then
        COMPOSE_FILE=docker-compose-$SERVICE.yml COMPOSE_PROJECT_NAME=$SERVICE docker-compose build $PULL $NOCACHE
    fi
    for IMAGE in $( eval "echo \${IMAGES_${SERVICE}}" ) ; do
        docker tag $FORCE ${SERVICE}_${IMAGE} ${REPOBASE}/${SERVICE}_${IMAGE}:${TAG}
        docker push $REPOBASE/${SERVICE}_${IMAGE}:${TAG}
    done
done

for IMAGE in $EXTRA_IMAGES ; do
    #cannot skip build as there would be no default local tag to refer to
    docker build $PULL $NOCACHE -t $REPOBASE/${IMAGE}:${TAG} ${IMAGE}/
    docker push $REPOBASE/${IMAGE}:${TAG}
done


