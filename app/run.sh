#!/bin/sh

# Copy example configuration if not exists
if [ ! -f /config/configuration.yaml ]; then
  cp ./configuration.yaml.example /config/configuration.yaml
fi

python ./s0pcm-reader.py -c /config

if [ -f /config/.noexit ]; then
  sleep 7d
fi
