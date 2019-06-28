#!/bin/bash

set -x
# Get script parameters
eval "$(jq -r '@sh "PARAM_JSON_PATH=\(.json_path)"')"
CAM_INSTANCE_ID=`jq --raw-output '.cam_instance_id' /tmp/${PARAM_JSON_PATH}`
jq -n --arg instance_id "$CAM_INSTANCE_ID" '{"instance_id":$instance_id}'