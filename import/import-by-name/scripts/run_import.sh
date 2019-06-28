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
        --cam_instance_name=*)
        PARAM_INSTANCE_NAME="${i#*=}"
        shift # past argument=value
        ;;
        --cam_instance_namespace=*)
        PARAM_INSTANCE_NAMESPACE="${i#*=}"
        shift # past argument=value
        ;;
        --cam_cloudconnection_name=*)
        PARAM_CC_NAME="${i#*=}"
        shift # past argument with no value
        ;;
        --cam_template_name=*)
        PARAM_TEMPLATE_NAME="${i#*=}"
        shift # past argument with no value
        ;;
        --cam_template_version_name=*)
        PARAM_TEMPLATE_VERSION_NAME="${i#*=}"
        shift # past argument with no value
        ;;
        --cloud_instance_id=*)
        PARAM_ID_FROM_PROVIDER="${i#*=}"
        shift # past argument with no value
        ;;
        *)
        # unknown option
        ;;
    esac
done

source ./functions.sh
run_cam_import ${PARAM_CAM_IP} ${PARAM_CAM_TOKEN} ${PARAM_CAM_TENANT} ${PARAM_INSTANCE_NAME} ${PARAM_INSTANCE_NAMESPACE} ${PARAM_CC_NAME} "${PARAM_TEMPLATE_NAME}" ${PARAM_TEMPLATE_VERSION_NAME} ${PARAM_ID_FROM_PROVIDER}
