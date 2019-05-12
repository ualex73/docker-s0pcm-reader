#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "ERROR: Specify version like '1.0', '1.1', etc"
  exit 1
fi

docker push ualex73/s0pcm-reader:arm64v8
docker push ualex73/s0pcm-reader:arm32v6
docker push ualex73/s0pcm-reader:amd64

docker push ualex73/s0pcm-reader:arm64v8-$VERSION
docker push ualex73/s0pcm-reader:arm32v6-$VERSION
docker push ualex73/s0pcm-reader:amd64-$VERSION

docker push ualex73/s0pcm-reader:$VERSION

docker push ualex73/s0pcm-reader:latest

