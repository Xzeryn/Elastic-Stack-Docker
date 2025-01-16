#!/bin/bash

export ES_CACERT=$(cat /usr/share/kibana/config/certs/ca/ca.crt)
#export ES_CACERT=`echo ${CACERT}  | tr '\n' "\\n"`
export ES_CAFINGERPRINT=`grep -v ^- /usr/share/kibana/config/certs/ca/ca.crt | base64 -d | sha256sum | awk '{ print $1 }'`

exec /usr/local/bin/kibana-docker