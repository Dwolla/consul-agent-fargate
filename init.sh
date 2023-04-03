#!/bin/sh

PRIVATE_IP=$(curl --silent "${ECS_CONTAINER_METADATA_URI_V4}/task" | \
             jq -r '.Containers | 
                    map(
                      select(.Name == "consul-agent") | 
                      .Networks | 
                      map(
                        select(.NetworkMode == "awsvpc") | 
                        .IPv4Addresses
                      )
                    ) | 
                    flatten | 
                    .[0]')
DATACENTER="$1"
CLUSTER="$2"
readonly PRIVATE_IP DATACENTER CLUSTER

echo "Binding to IP ${PRIVATE_IP} for datacenter ${DATACENTER} and joining consul.${CLUSTER}.${AWS_DEFAULT_REGION}.dwolla.net"

exec consul agent \
  -data-dir=/var/lib/consul \
  -datacenter="${DATACENTER}" \
  -join="consul.${CLUSTER}.${AWS_DEFAULT_REGION}.dwolla.net" \
  -bind="${PRIVATE_IP}"
