#!/bin/bash

STACK_VERSION=${ELASTIC_VERSION}
  
# Download Elastic Defend Security Artifacts
#STACK_VERSION="8.17.0"
cd /opt/elastic-packages/
curl -o downloads/endpoint/manifest/artifacts-${STACK_VERSION}.zip https://artifacts.security.elastic.co/downloads/endpoint/manifest/artifacts-${STACK_VERSION}.zip --create-dirs
zcat -q downloads/endpoint/manifest/artifacts-${STACK_VERSION}.zip | jq -r '.artifacts | to_entries[] | .value.relative_url' | xargs -I@ curl "https://artifacts.security.elastic.co@" --create-dirs -o ".@"