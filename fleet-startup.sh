#!/bin/bash

# Set EAR Url
export EAR_URL="http://"$DOCKER_HOST_IP":"$EAR_PORT
# Add Local EAR container to Elastic
curl --cacert /certs/ca/ca.crt -u elastic:${KIBANA_FLEET_PASSWORD} -X POST "${KIBANA_HOST}/api/fleet/agent_download_sources" \
-H "kbn-xsrf: true" \
-H "Content-Type: application/json" \
-d '{
  "name": "Local EAR",
  "host": "'"$EAR_URL"'",
  "is_default": true
}'

# Elastic Agent Container Entrypoint
set -eo pipefail
exec elastic-agent container "$@"