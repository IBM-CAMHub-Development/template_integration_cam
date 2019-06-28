function get_cam_bearer_token() {
    PARAM_CAM_IP=${1}
    PARAM_AUTH_USER=${2}
    PARAM_AUTH_PASSWORD=${3}
    CAM_TOKEN=`curl -k -X POST \
    https://$PARAM_CAM_IP:8443/idprovider/v1/auth/identitytoken \
    -H 'Content-Type: application/json' \
    -d '{
    "grant_type":"password",
    "username":"'$PARAM_AUTH_USER'",
    "password":"'$PARAM_AUTH_PASSWORD'",
    "scope":"openid"
    }' | jq --raw-output '.access_token'`
}

function get_cam_tenant() {
    PARAM_CAM_IP=${1}
    PARAM_CAM_TOKEN=${2}
    CAM_TENANT_ID=`curl -k -X GET \
    https://$PARAM_CAM_IP:30000/cam/tenant/api/v1/tenants/getTenantOnPrem \
    -H 'Content-Type: application/json' \
    -H 'Authorization: bearer '$PARAM_CAM_TOKEN | jq --raw-output '.id'`
}

function run_cam_import() {
    PARAM_CAM_IP=${1}
    PARAM_CAM_TOKEN=${2}
    PARAM_CAM_TENANT=${3}
    PARAM_INSTANCE_NAME=${4}
    PARAM_INSTANCE_NAMESPACE=${5}
    PARAM_CC_NAME="${6}"
    PARAM_TEMPLATE_NAME="${7}"
    PARAM_TEMPLATE_VERSION_NAME="${8}"
    PARAM_ID_FROM_PROVIDER=${9}

    CAM_INSTANCE_ID=`curl -k -X POST \
    'https://'$PARAM_CAM_IP':30000/cam/api/v1/stacks/import?tenantId='$PARAM_CAM_TENANT'&cloudOE_spaceGuid='$PARAM_INSTANCE_NAMESPACE \
    -H 'Content-Type: application/json' \
    -H 'Authorization: bearer '$PARAM_CAM_TOKEN \
    -d "{
    \"name\": \"$PARAM_INSTANCE_NAME\",
    \"cloudConnectionId\": \"$PARAM_CC_NAME\",
    \"templateId\": \"$PARAM_TEMPLATE_NAME\",
    \"templateVersionId\": \"$PARAM_TEMPLATE_VERSION_NAME\",
    \"idFromProvider\": \"$PARAM_ID_FROM_PROVIDER\"
    }" | jq --raw-output '.id'`
    jq -n --arg cam_instance_id "$CAM_INSTANCE_ID" '{"cam_instance_id":$cam_instance_id}' > ./cam.json
}

function wait_for_instance() {
    PARAM_CAM_IP=${1}
    PARAM_CAM_TOKEN=${2}
    PARAM_CAM_TENANT=${3}
    PARAM_INSTANCE_NAMESPACE=${4}
    PARAM_CAM_INSTANCE_ID=${5}

    # wait for the import job to finish
    attempts=0
    exit_code=-1
    CAM_INSTANCE_STATUS=""
    until [ $attempts -ge 5 ]
    do
        CAM_INSTANCE_STATUS=`curl -k -X POST \
        'https://'$PARAM_CAM_IP':30000/cam/api/v1/stacks/'$PARAM_CAM_INSTANCE_ID'/retrieve?tenantId='$PARAM_CAM_TENANT'&cloudOE_spaceGuid='$PARAM_INSTANCE_NAMESPACE \
        -H 'Content-Type: application/json' \
        -H 'Authorization: bearer '$PARAM_CAM_TOKEN | jq --raw-output '.status'`
        if [ "$CAM_INSTANCE_STATUS" == "SUCCESS" ]
        then
            exit_code=0
            break
        else
        sleep 5
        fi
        attempts=$[$attempts+1]
    done
    if [ $exit_code -eq 0 ]; then
        # dump the IP of the imported VM into a local file where it can be loaded from later in a script package
        IMPORTED_VM_IPV4=`curl -k -X POST \
        'https://'$PARAM_CAM_IP':30000/cam/api/v1/stacks/'$PARAM_CAM_INSTANCE_ID'/retrieve?tenantId='$PARAM_CAM_TENANT'&cloudOE_spaceGuid='$PARAM_INSTANCE_NAMESPACE \
        -H 'Content-Type: application/json' \
        -H 'Authorization: bearer '$PARAM_CAM_TOKEN | jq --raw-output '.data.details.resources[0].details.access_ip_v4'` 
        IMPORTED_VM_NAME=`curl -k -X POST \
        'https://'$PARAM_CAM_IP':30000/cam/api/v1/stacks/'$PARAM_CAM_INSTANCE_ID'/retrieve?tenantId='$PARAM_CAM_TENANT'&cloudOE_spaceGuid='$PARAM_INSTANCE_NAMESPACE \
        -H 'Content-Type: application/json' \
        -H 'Authorization: bearer '$PARAM_CAM_TOKEN | jq --raw-output '.data.details.resources[0].details.name'` 
    else
        exit -1
    fi
}

function delete_instance() {
    PARAM_CAM_IP=${1}
    PARAM_CAM_TOKEN=${2}
    PARAM_CAM_TENANT=${3}
    PARAM_INSTANCE_NAMESPACE=${4}
    PARAM_CAM_INSTANCE_ID=${5}

    CAM_INSTANCE_ID=`curl -k -X DELETE \
    'https://'$PARAM_CAM_IP':30000/cam/api/v1/stacks/'$PARAM_CAM_INSTANCE_ID'?tenantId='$PARAM_CAM_TENANT'&cloudOE_spaceGuid='$PARAM_INSTANCE_NAMESPACE \
    -H 'Content-Type: application/json' \
    -H 'Authorization: bearer '$PARAM_CAM_TOKEN `
}
