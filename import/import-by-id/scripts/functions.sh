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
    PARAM_AUTH_USER=${2}
    PARAM_AUTH_PASSWORD=${3}

    get_cam_bearer_token ${PARAM_CAM_IP} ${PARAM_AUTH_USER} ${PARAM_AUTH_PASSWORD}
    CAM_TENANT_ID=`curl -k -X GET \
    https://$PARAM_CAM_IP:30000/cam/tenant/api/v1/tenants/getTenantOnPrem \
    -H 'Content-Type: application/json' \
    -H 'Authorization: bearer '$CAM_TOKEN | jq --raw-output '.id'`
}

function run_cam_import() {
    PARAM_CAM_IP=${1}
    PARAM_AUTH_USER=${2}
    PARAM_AUTH_PASSWORD=${3}
    PARAM_INSTANCE_NAME=${4}
    PARAM_INSTANCE_NAMESPACE=${5}
    PARAM_CC_ID=${6}
    PARAM_TEMPLATE_ID=${7}
    PARAM_TEMPLATE_VERSION_ID=${8}
    PARAM_ID_FROM_PROVIDER=${9}
    get_cam_tenant ${PARAM_CAM_IP} ${PARAM_AUTH_USER} ${PARAM_AUTH_PASSWORD}
    #printf "\033[33m [Running the import VM command]\n\033[0m\n\033[0m\n"
    
    # call the import REST API
    CAM_INSTANCE_ID=`curl -k -X POST \
    'https://'$PARAM_CAM_IP':30000/cam/api/v1/stacks/import?tenantId='$CAM_TENANT_ID'&cloudOE_spaceGuid='$PARAM_INSTANCE_NAMESPACE \
    -H 'Content-Type: application/json' \
    -H 'Authorization: bearer '$CAM_TOKEN \
    -d '{
    "name": "'$PARAM_INSTANCE_NAME'",
    "cloudConnectionId": "'$PARAM_CC_ID'",
    "templateId": "'$PARAM_TEMPLATE_ID'",
    "templateVersionId": "'$PARAM_TEMPLATE_VERSION_ID'",
    "idFromProvider": "'$PARAM_ID_FROM_PROVIDER'"
    }' | jq --raw-output '.id'`

    # wait for the import job to finish

    attempts=0
    exit_code=-1
    CAM_INSTANCE_STATUS=""
    until [ $attempts -ge 5 ]
    do
        CAM_INSTANCE_STATUS=`curl -k -X POST \
        'https://'$PARAM_CAM_IP':30000/cam/api/v1/stacks/'$CAM_INSTANCE_ID'/retrieve?tenantId='$CAM_TENANT_ID'&cloudOE_spaceGuid='$PARAM_INSTANCE_NAMESPACE \
        -H 'Content-Type: application/json' \
        -H 'Authorization: bearer '$CAM_TOKEN | jq --raw-output '.status'`
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
        'https://'$PARAM_CAM_IP':30000/cam/api/v1/stacks/'$CAM_INSTANCE_ID'/retrieve?tenantId='$CAM_TENANT_ID'&cloudOE_spaceGuid='$PARAM_INSTANCE_NAMESPACE \
        -H 'Content-Type: application/json' \
        -H 'Authorization: bearer '$CAM_TOKEN | jq --raw-output '.data.details.resources[0].details.access_ip_v4'` 
    else
        exit -1
        #echo "Failed to import instance "$CAM_INSTANCE_ID ". Instance status is "$CAM_INSTANCE_STATUS
    fi
}
