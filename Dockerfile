ARG CONSUL_VERSION

FROM consul:$CONSUL_VERSION

COPY init.sh /init.sh

ENTRYPOINT ["/init.sh"]
CMD ["sandbox"]

HEALTHCHECK CMD curl --fail --silent http://localhost:8500/v1/agent/self > /dev/null
