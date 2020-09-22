#!/usr/bin/env bash

## Replace some well-known template variables in the horde config
if [[ -v EXPAND_CONFIGS ]]; then
    echo "EXPANDING CONFIG VARIABLES"
    if [[ -v MYSQL_DATABASE ]]; then
        # fix permissions of volume-provided configs
        chown root:postfix /etc/postfix/mysql*

        # NOTE: sed -i does not work here and fails with "Device or resource busy..."

        # fill in the virtual_mailbox_domains config
        sed -e "s/user = postfix/user = $MYSQL_USER/" \
            -e "s/password = postfix/password = $MYSQL_PASSWORD/" \
            -e "s/hosts = localhost/hosts = $MYSQL_HOSTNAME/" \
            -e "s/dbname = postfix/dbname = $MYSQL_DATABASE/" \
            /etc/postfix/mysql_virtual_mailbox_domains.cf > \
            /etc/postfix/mysql_virtual_mailbox_domains.cf.new
        cp  /etc/postfix/mysql_virtual_mailbox_domains.cf.new \
            /etc/postfix/mysql_virtual_mailbox_domains.cf
        rm /etc/postfix/mysql_virtual_mailbox_domains.cf.new

        # fill in the virtual_mailbox_maps config
        sed -e "s/user = postfix/user = $MYSQL_USER/" \
            -e "s/password = postfix/password = $MYSQL_PASSWORD/" \
            -e "s/hosts = localhost/hosts = $MYSQL_HOSTNAME/" \
            -e "s/dbname = postfix/dbname = $MYSQL_DATABASE/" \
            /etc/postfix/mysql_virtual_mailbox_maps.cf > \
            /etc/postfix/mysql_virtual_mailbox_maps.cf.new
        cp /etc/postfix/mysql_virtual_mailbox_maps.cf.new \
            /etc/postfix/mysql_virtual_mailbox_maps.cf
        rm /etc/postfix/mysql_virtual_mailbox_maps.cf.new

        # add the virtual_mailbox_* configs to the main.cf
        postconf virtual_mailbox_domains=mysql:/etc/postfix/mysql_virtual_mailbox_domains.cf
        postconf virtual_mailbox_maps=mysql:/etc/postfix/mysql_virtual_mailbox_maps.cf

        # LTMP configuration
        postconf virtual_transport=lmtp:inet:horde_dovecot:24
    fi
fi
exec "$@"
