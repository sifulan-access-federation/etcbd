#!/bin/bash

# set required permissions on mounted volumes

chgrp icingaweb2 /var/log/icingaweb2
chmod g+rwxs /var/log/icingaweb2

