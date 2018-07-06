#!/bin/bash

BASE_DIR=/

# render templates
for INST in $INST_NAMES ; do
  # Create visualizations and dashboard for each institution
  for SRC_FILE in $BASE_DIR/{visualization,dashboard}/*.template ; do
     # strip .template from the filename}
     DST_FILE="${SRC_FILE%_sampleinst.json.template}_${INST}.json"

     ### use envPlate for substitution
     ##LOCAL_INST="$INST"
     sed -e "s/\${LOCAL_INST:-[^}]*}/$INST/g" -e "s/\${LOCAL_INST}/$INST/g" < $SRC_FILE > $DST_FILE
  done

done

# Now invole /import_dashboards
$BASE_DIR/import_dashboards.sh -d $BASE_DIR -l http://elasticsearch:9200

