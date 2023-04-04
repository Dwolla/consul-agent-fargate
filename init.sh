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
ENVIRONMENT="$2"
readonly PRIVATE_IP DATACENTER ENVIRONMENT

echo "Binding to IP ${PRIVATE_IP} for datacenter ${DATACENTER} and joining consul.${AWS_DEFAULT_REGION}.${ENVIRONMENT}.dwolla.net"

exec consul agent \
  -data-dir=/var/lib/consul \
  -datacenter="${DATACENTER}" \
  -join="consul.${AWS_DEFAULT_REGION}.${ENVIRONMENT}.dwolla.net" \
  -bind="${PRIVATE_IP}"
