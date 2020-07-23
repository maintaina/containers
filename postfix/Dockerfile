FROM docker.io/opensuse/tumbleweed:latest
RUN zypper --non-interactive install --no-recommends --no-confirm postfix postfix-mysql && zypper clean -a

ENTRYPOINT ["postfix start-fg"]