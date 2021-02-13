#!/bin/bash

VERSION=$1

IMAGE="ualex73/s0pcm-reader"
ARCHLIST="amd64 arm32v6 arm32v7 arm64v8"

for ARCH in $ARCHLIST
do
  # Copy from main file
  cp Dockerfile Dockerfile.$ARCH

  # Append ARM architecture in from of none-AMD64
  echo $ARCH | grep "^arm" >/dev/null
  if [ $? -eq 0 ]; then
    sed -i "s/FROM python:alpine/FROM $ARCH\/python:alpine/" Dockerfile.$ARCH

    # Figure out the ARM platform type
    SARCH=`echo $ARCH | cut -c 1-5 | sed "s/arm32/arm/"`
    PLATFORM="--platform linux/$SARCH"
  else
    PLATFORM=""
  fi

  # Lets remove python:alpine from the repo, then we always use the latest from hub.docker.com
  docker rmi `cat Dockerfile.${ARCH} | head -1 | grep "^FROM " | cut -d " " -f 2`

  echo "========================================================================================"
  echo "========================================================================================"
  echo "=== Docker build * $ARCH * ==="
  echo "========================================================================================"
  echo "=== docker build $PLATFORM -f Dockerfile.${ARCH} -t $IMAGE:${ARCH} ."
  echo "========================================================================================"
  echo "========================================================================================"
  docker build $PLATFORM -f Dockerfile.${ARCH} -t $IMAGE:${ARCH} .

  # Tag it with a version
  if [ ! -z "$VERSION" ]; then
    docker tag $IMAGE:${ARCH} $IMAGE:${ARCH}-${VERSION}
  fi
done

if [ ! -z "$VERSION" ]; then
  docker tag $IMAGE:amd64 $IMAGE:$VERSION
  echo "=== Push * $ARCH * to hub.docker.com ==="

  for ARCH in $ARCHLIST
  do
    docker push $IMAGE:$ARCH
    docker push $IMAGE:$ARCH-$VERSION
  done

  # Do the multi-arch push of latest
  ./manifest-tool-linux-amd64 push from-spec multi-arch-manifest.yaml
fi

# don't care about ARM and AMD tags in my local repo ;)
for ARCH in $ARCHLIST
do
  echo "=== Deleting * $ARCH * from local repo ==="
  docker rmi $IMAGE:$ARCH $IMAGE:$ARCH-$VERSION
done

# End
