#!/bin/bash


AWS_PROFILE=default
app="docker.test"

if [ ! -f $HOME/.aws/credentials ]; then
    echo "You should setup AWS Profile before running this container"
    echo "https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html"
    exit 1;
fi

AWS_ACCESS_KEY_ID=$(aws --profile ${AWS_PROFILE} configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(aws --profile ${AWS_PROFILE} configure get aws_secret_access_key)

docker build -t ${app} .

check=$(docker ps | grep ${app})
if [ ! -z "$check" ]; then
    echo "Container ${app} already running. Stoping..."
    docker stop ${app}
fi

docker run --rm -d -p 56733:80 \
  --name=${app} \
  -v $PWD:/app \
  --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
  --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
  ${app}
