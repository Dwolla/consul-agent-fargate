#!/bin/ash
# shellcheck shell=dash
set -o nounset -o errexit -o pipefail

if [ -z "$1" ]; then
  echo "The environment must be provided as the first argument to this script, but no value was passed." >> /dev/stderr
  exit 42
fi
ENVIRONMENT="$1"
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
ECS_REGION=$(curl --silent "${ECS_CONTAINER_METADATA_URI_V4}/task" | \
             jq -r '.AvailabilityZone' | \
             sed -e 's/[a-z]$//')
readonly ECS_REGION ENVIRONMENT PRIVATE_IP

if [ "${ECS_REGION}" != "us-west-2" ]; then
    DATACENTER=${ECS_REGION}'_'${ENVIRONMENT}
else
    DATACENTER=${ENVIRONMENT}
fi
readonly DATACENTER

echo "Binding to IP ${PRIVATE_IP} for datacenter ${DATACENTER} and joining consul.${ECS_REGION}.${ENVIRONMENT}.dwolla.net"

exec consul agent \
  -data-dir=/var/lib/consul \
  -datacenter="${DATACENTER}" \
  -retry-join "provider=aws region=${ECS_REGION} tag_key=Name tag_value=${ENVIRONMENT}-consul" \
  -enable-script-checks \
  -bind="${PRIVATE_IP}"
