#!/usr/bin/env bash
set -e
PROJECT_NAME=carla_ml

./docker_mlgl/stop_sandbox.sh $PROJECT_NAME
# Build parent image
./docker_mlgl/build.sh mlgl_sandbox
docker build -t $PROJECT_NAME .
./docker_mlgl/start_sandbox.sh $PROJECT_NAME .