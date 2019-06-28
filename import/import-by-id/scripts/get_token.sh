#!/bin/bash

set -x
# Get script parameters
eval "$(jq -r '@sh "PARAM_CAM_IP=\(.cam_host_name) 
PARAM_AUTH_USER=\(.cam_user_name) 
PARAM_AUTH_PASSWORD=\(.cam_password)"')"

source ./scripts/functions.sh
get_cam_bearer_token ${PARAM_CAM_IP} ${PARAM_AUTH_USER} ${PARAM_AUTH_PASSWORD}
jq -n --arg cam_token "$CAM_TOKEN" '{"token":$cam_token}'