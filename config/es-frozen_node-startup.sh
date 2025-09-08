#!/bin/bash
set -e

# Files created by Elasticsearch should always be group writable too
umask 0002

sleep 5
# Configure Elastic to use MinIO S3 container
curl --cacert /usr/share/elasticsearch/config/certs/ca/ca.crt -u elastic:${ELASTIC_PASSWORD} -X PUT "https://es01:9200/_snapshot/minio_repository" \
-H "Content-Type: application/json" \
-d '{
  "type": "s3",
  "settings": {
    "bucket": "elastic",
    "endpoint": "http://minio:9000",
    "path_style_access": "true"
  }
}'

sleep 15
# Execute normal ES startup
/usr/local/bin/docker-entrypoint.sh

