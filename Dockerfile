FROM alpine:3.22

ARG CONSUL_VERSION=1.1.1
ARG TARGETARCH
ARG HASHICORP_RELEASES=https://releases.hashicorp.com
ARG HASHICORP_PGP_FINGERPRINT=C874011F0AB405110D02105534365D9472D7468F

ENV CONSUL_VERSION=${CONSUL_VERSION}

RUN set -eux; \
    apk add --no-cache ca-certificates curl jq; \
    apk add --no-cache --virtual .verify-deps gnupg; \
    arch="${TARGETARCH:-$(apk --print-arch | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')}"; \
    workdir="$(mktemp -d)"; \
    cd "${workdir}"; \
    export GNUPGHOME="${workdir}/gnupg"; \
    mkdir -m 700 "${GNUPGHOME}"; \
    curl --fail --silent --show-error --location -o hashicorp.asc https://www.hashicorp.com/.well-known/pgp-key.txt; \
    gpg --batch --quiet --import hashicorp.asc; \
    base="${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}"; \
    curl --fail --silent --show-error --location -O "${base}_SHA256SUMS" -O "${base}_SHA256SUMS.sig" -O "${base}_linux_${arch}.zip"; \
    gpg --batch --status-fd 1 --verify "consul_${CONSUL_VERSION}_SHA256SUMS.sig" "consul_${CONSUL_VERSION}_SHA256SUMS" \
      | grep -Eq "^\[GNUPG:\] VALIDSIG .* ${HASHICORP_PGP_FINGERPRINT}\$"; \
    grep " consul_${CONSUL_VERSION}_linux_${arch}.zip\$" "consul_${CONSUL_VERSION}_SHA256SUMS" | sha256sum -c -; \
    unzip -d /bin "consul_${CONSUL_VERSION}_linux_${arch}.zip"; \
    chmod 0755 /bin/consul; \
    cd /; \
    rm -rf "${workdir}"; \
    apk del .verify-deps; \
    consul version

COPY init.sh /init.sh

ENTRYPOINT ["/init.sh"]
CMD ["sandbox"]

HEALTHCHECK CMD curl --fail --silent http://localhost:8500/v1/agent/self > /dev/null
