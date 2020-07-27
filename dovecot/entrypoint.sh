#!/usr/bin/env bash

## Replace some well-known template variables in the horde config
if [[ -v EXPAND_CONFIGS ]]; then
    echo "EXPANDING CONFIG VARIABLES"
    if [[ -v MYSQL_DATABASE ]]; then
        echo 
        sed -i "s/connect = .*/connect = 'host=$MYSQL_HOSTNAME dbname=$MYSQL_DATABASE user=$MYSQL_USER password=$MYSQL_PASSWORD';/g" /etc/dovecot/dovecot-sql.conf.ext
    fi
fi
exec "$@"
