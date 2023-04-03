FROM consul:1.1.1

COPY init.sh /init.sh

ENTRYPOINT ["/init.sh"]
CMD ["sandbox", "sandbox"]
