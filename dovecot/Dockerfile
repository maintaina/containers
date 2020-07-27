FROM docker.io/dovecot/dovecot:latest
COPY ./dovecot /etc/dovecot
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/dovecot", "-F"]
