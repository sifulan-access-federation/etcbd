#!/bin/bash

# workaround an issue with docker+icingaweb2 - module conf not visible until the directory is touched

ls -lR /etc/icingaweb2/modules/ /etc/icingaweb2/enabledModules/ > /dev/null

