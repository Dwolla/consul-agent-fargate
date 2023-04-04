ARG CONSUL_VERSION

FROM consul:$CONSUL_VERSION

COPY init.sh /init.sh

ENTRYPOINT ["/init.sh"]
CMD ["sandbox"]
