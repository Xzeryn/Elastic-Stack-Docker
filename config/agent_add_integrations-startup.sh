#!/bin/bash

# Add Custom Logs (Filestream) integration to Fleet Policy through Kibana API
curl --cacert /certs/ca/ca.crt -u elastic:${KIBANA_FLEET_PASSWORD} -X POST "${KIBANA_HOST}/api/fleet/package_policies" \
-H "kbn-xsrf: true" \
-H "Content-Type: application/json" \
-d '{
  "policy_id": "docker-container-policy",
  "package": {
    "name": "filestream",
    "version": "'"$INTEGRATION_FILESTREAM_VERSION"'"
  },
  "name": "filestream-docker_agent",
  "description": "",
  "namespace": "",
  "inputs": {
    "filestream-filestream": {
      "enabled": true,
      "streams": {
        "filestream.generic": {
          "enabled": true,
          "vars": {
            "paths": [
              "/tmp/ingest_data/*"
            ],
            "clean_inactive": "-1",
            "data_stream.dataset": "filestream.generic",
            "tags": []
          }
        }
      }
    }
  }
}'

# Add Custom TCP Logs integration to Fleet Policy through Kibana API
curl --cacert /certs/ca/ca.crt -u elastic:${KIBANA_FLEET_PASSWORD} -X POST "${KIBANA_HOST}/api/fleet/package_policies" \
-H "kbn-xsrf: true" \
-H "Content-Type: application/json" \
-d '{
  "policy_id": "docker-container-policy",
  "package": {
    "name": "tcp",
    "version": "'"$INTEGRATION_TCP_LOGS_VERSION"'"
  },
  "name": "tcp-logs-docker_agent",
  "description": "",
  "namespace": "",
  "inputs": {
    "tcp-tcp": {
      "enabled": true,
      "streams": {
        "tcp.tcp": {
          "enabled": true,
          "vars": {
            "listen_address": "localhost",
            "listen_port": "9004",
            "data_stream.dataset": "tcp.generic",
            "tags": [],
            "syslog": true,
            "custom": ""
          }
        }
      }
    }
  }
}'

# Add Custom UDP Logs integration to Fleet Policy through Kibana API
curl --cacert /certs/ca/ca.crt -u elastic:${KIBANA_FLEET_PASSWORD} -X POST "${KIBANA_HOST}/api/fleet/package_policies" \
-H "kbn-xsrf: true" \
-H "Content-Type: application/json" \
-d '{
  "policy_id": "docker-container-policy",
  "package": {
    "name": "udp",
    "version": "'"$INTEGRATION_UDP_LOGS_VERSION"'"
  },
  "name": "udp-logs-docker_agent",
  "description": "",
  "namespace": "",
  "inputs": {
    "udp-udp": {
      "enabled": true,
      "streams": {
        "udp.udp": {
          "enabled": true,
          "vars": {
            "listen_address": "localhost",
            "listen_port": "9003",
            "data_stream.dataset": "udp.generic",
            "max_message_size": "10KiB",
            "keep_null": false,
            "tags": [],
            "syslog": true,
            "custom": ""
          }
        }
      }
    }
  }
}'

# Elastic Agent Container Entrypoint 
set -eo pipefail
exec elastic-agent container "$@"