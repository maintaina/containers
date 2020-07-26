#!/usr/bin/env bash
echo "Config stage"

## copy files from /srv/original_config/apps to config dirs
cd /srv/original_config/apps
for app in *
do
    app=${app%*/}
    for file in $app/*
    do
        if [ -f "/srv/www/horde/web/$file" ]; then
            echo "$file already exists"
        else 
            cp $file /srv/www/horde/web/$file
        fi
    done
done

## ADD composer bin_dir to PATH
PATH=$PATH:/srv/www/horde/vendor/bin

## Replace some well-known template variables in the horde config
if [[ -v EXPAND_CONFIG ]]; then
    echo "EXPANDING CONFIG VARIABLES"
    if [[ -v MYSQL_DATABASE ]]; then
        echo 
        sed -i "s/conf\['sql'\]\['database'\].*/conf['sql']['database'] = '$MYSQL_DATABASE'/g" /srv/www/horde/web/horde/config/conf.php
    fi
    if [[ -v MYSQL_HOSTNAME ]]; then
        echo 
        sed -i "s/conf\['sql'\]\['hostspec'\].*/conf['sql']['hostspec'] = '$MYSQL_HOSTNAME'/g" /srv/www/horde/web/horde/config/conf.php
    fi
    if [[ -v MYSQL_USER ]]; then
        echo 
        sed -i "s/conf\['sql'\]\['username'\].*/conf['sql']['username'] = '$MYSQL_USER'/g" /srv/www/horde/web/horde/config/conf.php
    fi
    if [[ -v MYSQL_PASSWORD ]]; then
        echo 
        sed -i "s/conf\['sql'\]\['password'\].*/conf['sql']['password'] = '$MYSQL_PASSWORD'/g" /srv/www/horde/web/horde/config/conf.php
    fi
fi

## TODO: Wait for DB connection to succeed
## TODO: BACKGROUND THIS and everything besides making apache pid one

## TODO: Run migrations N times
if [[ -v HORDE_MIGRATION_RUNS ]]
then
    for i in {1..$HORDE_MIGRATION_RUNS}
    do
        php /srv/www/horde/web/horde/bin/horde-db-migrate
   done
fi

## TODO: Inject initial horde user
if [[ -v HORDE_ADMIN_USER ]]; then
    echo "Injecting Admin User $HORDE_ADMIN_USER"
    php /srv/www/horde/web/horde/bin/createUser.php $HORDE_ADMIN_USER $HORDE_ADMIN_PASSWORD
fi

echo "Handing over to pid 1 command"
exec "$@"
