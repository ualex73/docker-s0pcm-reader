#!/bin/bash

docker build -t ualex73/s0pcm-reader .
/usr/local/bin/docker-compose -f /docker/script/run/docker-compose.yaml up -d s0pcm
sleep 2
/docker/script/other/exec.sh s0pcm

