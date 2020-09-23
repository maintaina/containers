FROM docker.io/opensuse/tumbleweed:latest
RUN zypper --non-interactive install --no-recommends --no-confirm postfix postfix-mysql && zypper clean -a

COPY ./postfix /etc/postfix
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["postfix", "start-fg"]
