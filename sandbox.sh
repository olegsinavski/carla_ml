#!/usr/bin/env bash
set -e
PROJECT_NAME=carla_ml

# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
./docker_mlgl/stop_sandbox.sh $PROJECT_NAME
# Build parent image
./docker_mlgl/build.sh mlgl_sandbox
docker build -t $PROJECT_NAME $SCRIPT_DIR
./docker_mlgl/start_sandbox.sh $PROJECT_NAME $SCRIPT_DIR