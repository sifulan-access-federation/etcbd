#!/bin/bash

echo "Removing elasticsearch queue limit size..."
docker exec elasticsearch curl -Ss -HContent-Type:application/json -XPUT elasticsearch:9200/_cluster/settings -d '{ "persistent" : { "thread_pool.search.queue_size" : -1 } }'
echo "...done"

echo "Loading dashboards and visualizations..."
docker exec kibana /load_dashboards.sh
echo "...done"

