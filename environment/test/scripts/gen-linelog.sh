#!/bin/bash

INST_NAMES="reannz.co.nz standstone.ac.nz sandstone.edu.au limestone.ac.nz limestone.edu.au"

for IDP_INST in $INST_NAMES ; do
  for SP_INST in $INST_NAMES ; do
    echo "\"$( date +'%F %T' )\",\"Access-Accept\",\"$( echo $IDP_INST | shasum | cut -f 1 -d ' ' )\",\"1$SP_INST\",\"127.0.0.1\",\"127.0.0.1\",\"testing-client\",\"user@$IDP_INST\""
  done
done


# "2016-01-13 12:39:43","Access-Accept","496d42c40d40af717d9ea02c4b248a09ff58757a","reannz.co.nz","210.7.47.27","210.7.40.57","reannz.ac.nz-1","sam@sandstone.edu.au"


