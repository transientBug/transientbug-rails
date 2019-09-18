#!/bin/bash
set -Eeuxo pipefail

token=$1
action=$2
event=$3

pushd ".github/actions/${action}"
docker_image=$(docker build . 2>/dev/null | awk '/Successfully built/{print $NF}')
popd

home_dir="/github/home"
workflow_dir="/github/workflow"
workspace_dir="/github/workspace"
event_path=${workflow_dir}"/event.json"
sha=$(git rev-parse HEAD)
ref=$(git rev-parse --abbrev-ref HEAD)
actor=$(whoami)

home_temp_dir=$(pwd)"/tmp/home/"
workflow_temp_dir=$(pwd)"/tmp/workflow/"

mkdir -p ${home_temp_dir}
mkdir -p ${workflow_temp_dir}

event_temp_path=${workflow_temp_dir}"/event.json"

cp ${event} ${event_temp_path}

docker run \
  --workdir ${workspace_dir} \
  --rm \
  -e GITHUB_TOKEN=${token} \
  -e HOME=${home_dir} \
  -e GITHUB_WORKFLOW="test.sh" \
  -e GITHUB_ACTION=${action} \
  -e GITHUB_ACTOR=${actor} \
  -e GITHUB_REPOSITORY="transientbug/transientbug-rails" \
  -e GITHUB_EVENT_NAME="manual" \
  -e GITHUB_EVENT_PATH=${event_path} \
  -e GITHUB_WORKSPACE=${workspace_dir} \
  -e GITHUB_SHA=${sha} \
  -e GITHUB_REF=${ref} \
  -v "/var/run/docker.sock":"/var/run/docker.sock" \
  -v ${home_temp_dir}:${home_dir} \
  -v ${workflow_temp_dir}:${workflow_dir}\
  -v $(pwd):${workspace_dir} \
  ${docker_image}

docker rmi ${docker_image}
rm -f ${home_temp_dir}
rm -f ${workflow_temp_dir}
