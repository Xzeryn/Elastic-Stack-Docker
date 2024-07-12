#!/bin/bash

# Add Custom Logs integration to Fleet Policy through Kibana API
curl --cacert /certs/ca/ca.crt -u elastic:${KIBANA_FLEET_PASSWORD} -X POST "${KIBANA_HOST}/api/fleet/package_policies" \
-H "kbn-xsrf: true" \
-H "Content-Type: application/json" \
-d '{
  "policy_id": "docker-container-policy",
  "package": {
    "name": "log",
    "version": "'"$INTEGRATION_LOGS_VERSION"'"
  },
  "name": "log-docker_agent",
  "description": "",
  "namespace": "",
  "inputs": {
    "logs-logfile": {
      "enabled": true,
      "streams": {
        "log.logs": {
          "enabled": true,
          "vars": {
            "paths": [
              "/tmp/ingest_data/*"
            ],
            "exclude_files": [],
            "ignore_older": "72h",
            "data_stream.dataset": "generic",
            "tags": [],
            "custom": ""
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
        "tcp.generic": {
          "enabled": true,
          "vars": {
            "listen_address": "localhost",
            "listen_port": "9004",
            "data_stream.dataset": "tcp.generic",
            "tags": [],
            "syslog": true,
            "syslog_options": "field: message\n#format: auto\n#timezone: Local\n",
            "ssl": "#certificate: |\n#    -----BEGIN CERTIFICATE-----\n#    ...\n#    -----END CERTIFICATE-----\n#key: |\n#    -----BEGIN PRIVATE KEY-----\n#    ...\n#    -----END PRIVATE KEY-----\n",
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
        "udp.generic": {
          "enabled": true,
          "vars": {
            "listen_address": "localhost",
            "listen_port": "9003",
            "data_stream.dataset": "udp.generic",
            "max_message_size": "10KiB",
            "keep_null": false,
            "tags": [],
            "syslog": true,
            "syslog_options": "field: message\n#format: auto\n#timezone: Local\n",
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