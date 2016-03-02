#!/bin/bash

# workaround an issue with docker+icingaweb2 - module conf not visible until the directory is touched

# this may have to do with realpath cache in PHP - accessing all files under
# /etc/icingaweb2 solves the problem

ls -lR /etc/icingaweb2/modules/ /etc/icingaweb2/enabledModules/ > /dev/null

