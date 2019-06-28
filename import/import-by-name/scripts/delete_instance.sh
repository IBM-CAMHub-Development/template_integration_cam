#!/bin/bash

set -x
# Assign parameters
for i in "$@"
do
    case $i in
        --cam_host_name=*)
        PARAM_CAM_IP="${i#*=}"
        shift # past argument=value
        ;;
        --cam_token=*)
        PARAM_CAM_TOKEN="${i#*=}"
        shift # past argument=value
        ;;
        --cam_tenant=*)
        PARAM_CAM_TENANT="${i#*=}"
        shift # past argument=value
        ;;
        --cam_instance_namespace=*)
        PARAM_INSTANCE_NAMESPACE="${i#*=}"
        shift # past argument=value
        ;;
        --cam_instance_id=*)
        PARAM_INSTANCE_ID="${i#*=}"
        shift # past argument=value
        ;;
        *)
        # unknown option
        ;;
    esac
done

source ./functions.sh
delete_instance ${PARAM_CAM_IP} ${PARAM_CAM_TOKEN} ${PARAM_CAM_TENANT} ${PARAM_INSTANCE_NAMESPACE} ${PARAM_INSTANCE_ID}
