#!/bin/bash

set -x
# Get script parameters
eval "$(jq -r '@sh "PARAM_CAM_IP=\(.host_name) 
PARAM_AUTH_USER=\(.user_name) 
PARAM_AUTH_PASSWORD=\(.password) 
PARAM_INSTANCE_NAME=\(.instance_name) 
PARAM_INSTANCE_NAMESPACE=\(.instance_namespace) 
PARAM_CC_NAME=\(.cloud_connection_name) 
PARAM_TEMPLATE_NAME=\(.template_name) 
PARAM_TEMPLATE_VERSION_NAME=\(.template_version_name) 
PARAM_ID_FROM_PROVIDER=\(.id_from_provider)"')"

source ./scripts/functions.sh

run_cam_import ${PARAM_CAM_IP} ${PARAM_AUTH_USER} ${PARAM_AUTH_PASSWORD} ${PARAM_INSTANCE_NAME} ${PARAM_INSTANCE_NAMESPACE} "${PARAM_CC_NAME}" "${PARAM_TEMPLATE_NAME}" "${PARAM_TEMPLATE_VERSION_NAME}" ${PARAM_ID_FROM_PROVIDER}
  
jq -n --arg ipv4 "$IMPORTED_VM_IPV4" --arg name "$IMPORTED_VM_NAME" '{"ipv4":$ipv4, "name":$name}'