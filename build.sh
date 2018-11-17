#!/bin/bash

VERSION=$1

if [ ! -z "$VERSION" ]; then
  VERSION="-${VERSION}"
fi

for ARCH in amd64  arm32v6 arm64v8
do
  docker build -f Dockerfile.${ARCH} -t ualex73/s0pcm-reader:${ARCH} .

  # Tag it with a version
  if [ ! -z "$VERSION" ]; then
    docker tag ualex73/s0pcm-reader:${ARCH} ualex73/s0pcm-reader:${ARCH}${VERSION}
  fi
done

if [ ! -z "$VERSION" ]; then
  docker tag ualex73/s0pcm-reader:amd64 ualex73/s0pcm-reader:latest
fi
