#!/usr/bin/env bash

## Replace some well-known template variables in the horde config
if [[ -v EXPAND_CONFIGS ]]; then
    echo "EXPANDING CONFIG VARIABLES"
    if [[ -v MYSQL_DATABASE ]]; then
        echo "Filling out *maps.cf templates"
        sed -i -e "s/user = postfix/user = $MYSQL_USER/" \
               -e "s/password = postfix/password = $MYSQL_PASSWORD/" \
               -e "s/hosts = localhost/hosts = $MYSQL_HOSTNAME/" \
               -e "s/dbname = postfix/dbname = $MYSQL_DATABASE/" \
            /etc/postfix/mysql_virtual_alias_maps.cf \
            /etc/postfix/mysql_virtual_domains_maps.cf \
            /etc/postfix/mysql_virtual_mailbox_maps.cf
    fi
fi
exec "$@"
