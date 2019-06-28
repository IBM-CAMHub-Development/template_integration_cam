#!/bin/bash

set -x
# Get script parameters
eval "$(jq -r '@sh "PARAM_CAM_IP=\(.cam_host_name)
PARAM_CAM_TOKEN=\(.cam_token)"')"

source ./scripts/functions.sh
get_cam_tenant ${PARAM_CAM_IP} ${PARAM_CAM_TOKEN}
jq -n --arg tenant_id "$CAM_TENANT_ID" '{"tenant":$tenant_id}'