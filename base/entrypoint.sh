#!/usr/bin/env bash
echo "Config stage"

## copy files from /srv/original_config/apps to config dirs
cd /srv/original_config/apps
for app in *     # list directories in the form "/tmp/dirname/"
do
    app=${app%*/}      # remove the trailing "/"
    for file in $app/*     # list directories in the form "/tmp/dirname/"
    do
        if [ -f "/srv/www/horde/web/$file" ]; then
            echo "$file already exists"
        else 
            cp $file /srv/www/horde/web/$file
        fi
    done
done
## Replace some well-known template variables in the horde config
#!/usr/bin/env bash
echo "Config stage"

## ADD composer bin_dir to PATH
PATH=$PATH:/srv/www/horde/vendor/bin

## copy files from /srv/original_config/apps to config dirs
cd /srv/original_config/apps
for app in *     # list directories in the form "/tmp/dirname/"
do
    app=${app%*/}      # remove the trailing "/"
    for file in $app/*     # list directories in the form "/tmp/dirname/"
    do
        if [ -f "/srv/www/horde/web/$file" ]; then
            echo "$file already exists"
        else 
            cp $file /srv/www/horde/web/$file
        fi
    done
done
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
## TODO: BACKGROUND THIS

## TODO: Run migrations N times

## TODO: Inject initial horde user

echo "Handing over to pid 1 command"
exec "$@"
## Inject a github token into composer if provided
if [[ -v GITHUB_COMPOSER_TOKEN ]]
then
    echo "Configuring authentication to Github API for composer"
    composer config -g github-oauth.github.com $GITHUB_COMPOSER_TOKEN
fi


## TODO: Wait for DB connection to succeed
echo "Waiting for the database to become accessible. You may see error messages for a while."


## TODO: Run migrations N times

## Inject initial horde user
if [[ -v HORDE_ADMIN_USER ]]; then
    echo "Injecting Admin User $HORDE_ADMIN_USER"
    php /srv/www/horde/web/horde/bin/createUser.php $HORDE_ADMIN_USER $HORDE_ADMIN_PASSWORD
fi

echo "Handing over to pid 1 command"
exec "$@"