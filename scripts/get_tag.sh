#!/bin/sh

export app_name=$1
export env=$2
export aws_profile=$3
export aws_region=$4

export SERVICE_ARN=$(aws ecs --profile ${aws_profile} --region ${aws_region} list-services --cluster ${app_name}-${env}-cluster | jq -r .serviceArns[])
export TASKDEF_ARN=$(aws ecs --profile ${aws_profile} --region ${aws_region} describe-services --cluster ${app_name}-${env}-cluster --service ${SERVICE_ARN} | jq -r .services[].taskDefinition)
export EXISTING_TAG=$(aws ecs --profile ${aws_profile} --region ${aws_region} describe-task-definition --task-definition ${TASKDEF_ARN} | jq -r .taskDefinition.containerDefinitions[].image | tr ':' ' ' | awk '{print $2}')

if [ "$EXISTING_TAG" != "" ] && [ ! "$TAG" ]; then
    echo "Setting tag: $EXISTING_TAG"
    export TAG=$EXISTING_TAG
fi
