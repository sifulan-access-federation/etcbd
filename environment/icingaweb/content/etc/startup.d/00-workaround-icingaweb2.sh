#!/bin/bash

# workaround an issue with docker+icingaweb2 - module conf not visible until the directory is touched

ls -l /etc/icingaweb2/modules/ > /dev/null

