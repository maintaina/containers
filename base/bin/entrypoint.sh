#!/usr/bin/env bash
echo "Config stage"

## copy files from /srv/original_config/apps to config dirs
/usr/local/bin/copy-original-configs

## FIXUP VARIABLES IF THEY CONTAIN LEADING/TRAILING QUOTES

tmp="${GITHUB_COMPOSER_TOKEN%\"}"
tmp="${tmp#\"}"
export GITHUB_COMPOSER_TOKEN=$tmp

tmp="${MYSQL_PASSWORD%\"}"
tmp="${tmp#\"}"
export MYSQL_PASSWORD=$tmp

tmp="${HORDE_ADMIN_PASSWORD%\"}"
tmp="${tmp#\"}"
export HORDE_ADMIN_PASSWORD=$tmp


## ADD composer bin_dir to PATH
echo "export PATH=\$PATH:/srv/www/horde/vendor/bin" > /root/.bashrc


if [[ ! -z $GITHUB_COMPOSER_TOKEN ]]
then
    echo "Configuring authentication to Github API for composer"
    composer config -g github-oauth.github.com $GITHUB_COMPOSER_TOKEN
fi


## Replace some well-known template variables in the horde config
if [[ -v EXPAND_CONFIGS ]]; then
    echo "EXPANDING CONFIG VARIABLES"
    if [[ -v MYSQL_DATABASE ]]; then
        echo 
        sed -i "s/conf\['sql'\]\['database'\].*/conf['sql']['database'] = '$MYSQL_DATABASE';/g" /srv/www/horde/web/horde/config/conf.php
    fi
    if [[ -v MYSQL_HOSTNAME ]]; then
        echo 
        sed -i "s/conf\['sql'\]\['hostspec'\].*/conf['sql']['hostspec'] = '$MYSQL_HOSTNAME';/g" /srv/www/horde/web/horde/config/conf.php
    fi
    if [[ -v MYSQL_USER ]]; then
        echo 
        sed -i "s/conf\['sql'\]\['username'\].*/conf['sql']['username'] = '$MYSQL_USER';/g" /srv/www/horde/web/horde/config/conf.php
    fi
    if [[ -v MYSQL_PASSWORD ]]; then
        echo 
        sed -i "s/conf\['sql'\]\['password'\].*/conf['sql']['password'] = '$MYSQL_PASSWORD';/g" /srv/www/horde/web/horde/config/conf.php
    fi
fi

## if a composer-on-bootstrap.sh hook exists, run it
## The hook should take care itself if it should only run for the very first startup.
if [[ -f "/usr/local/bin/composer-on-bootstrap" ]]; then
    echo "Found composer-on-bootstrap. Running ..."
    /usr/local/bin/composer-on-bootstrap
fi

## TODO: BACKGROUND THIS and everything besides making the main process pid 1
## Wait for DB connection to succeed
## TODO: Make this optional for No-DB scenarios
echo "SHOW DATABASES" > /root/conntest.sql
echo "WAITING FOR DB CONNECTION TO SUCCEED"
echo "For new setups, this may take some time. You may see error messages"
until php /srv/www/horde/web/horde/bin/horde-sql-shell /root/conntest.sql &> /dev/null
do
    sleep 3
    echo "RETRYING"
done
echo "CONNECTION ESTABLISHED"

## Run migrations N times
if [[ -v HORDE_MIGRATION_RUNS ]]
then
    for ((i=1;i<=HORDE_MIGRATION_RUNS;i++))
    do
        echo "Running Horde Schema Migrations: #$i"
        php /srv/www/horde/web/horde/bin/horde-db-migrate
   done
fi

## if hordectl is installed and /srv/original_config/hordectl exists, run all yml files through it
/usr/local/bin/run-hordectl

# Inject initial user or change his password if he already exists
if [[ -v HORDE_ADMIN_USER ]]; then
    echo "Injecting Admin User $HORDE_ADMIN_USER"
    php /srv/www/horde/vendor/bin/hordectl patch user $HORDE_ADMIN_USER $HORDE_ADMIN_PASSWORD
fi

echo "Handing over to pid 1 command"
exec "$@"
