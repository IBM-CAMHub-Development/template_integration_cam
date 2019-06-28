#!/bin/bash

set -x
# Get script parameters
eval "$(jq -r '@sh "PARAM_CAM_IP=\(.cam_host_name) 
PARAM_CAM_TOKEN=\(.cam_token) 
PARAM_CAM_TENANT=\(.cam_tenant_id) 
PARAM_CAM_INSTANCE_ID=\(.cam_instance_id)
PARAM_INSTANCE_NAMESPACE=\(.cam_instance_namespace)"')"

source ./scripts/functions.sh

wait_for_instance ${PARAM_CAM_IP} ${PARAM_CAM_TOKEN} ${PARAM_CAM_TENANT} ${PARAM_INSTANCE_NAMESPACE} ${PARAM_CAM_INSTANCE_ID}
jq -n --arg ipv4 "$IMPORTED_VM_IPV4" --arg name "$IMPORTED_VM_NAME" '{"ipv4":$ipv4, "name":$name}'