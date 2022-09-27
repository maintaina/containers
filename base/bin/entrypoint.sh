#!/usr/bin/env bash
echo "Config stage"
# if ENABLE_DEVELOPER_MODE=yes then install the developer tools marked with yes (e.g. VIM=yes)
if [[ -v ENABLE_DEVELOPER_MODE && -n "$ENABLE_DEVELOPER_MODE" && $ENABLE_DEVELOPER_MODE == "yes" ]]; then
    echo "developer-mode is enabled: starting installation of developer-tools"
    PHP_VERSION=$(php -r "echo PHP_VERSION;")

    if [[ $PHP_VERSION == 7.* ]]; then
        zypper -n install php7-xdebug
    fi
    if [[ $PHP_VERSION == 8.* ]]; then
        zypper -n install php8-xdebug
    fi

    xdebug_major_version="$(rpm -qa '*xdebug*' --qf "%{VERSION}\n" | cut -d'.' -f1)"
    if [[ $xdebug_major_version -eq 2 ]]; then
        # configuration for Xdebug 2.9.5 as distributed by openSUSE Leap 15.3
        {
            echo "xdebug.remote_enable = 1";
            echo "xdebug.remote_autostart = 1";
            echo "xdebug.remote_port = 9000";
        } >> /etc/php7/conf.d/xdebug.ini
    elif [[ $xdebug_major_version -eq 3 ]]; then
        # NOTE: untested as of 2022-03-04, as only Tumbleweed has Xdebug 3
        {
            echo "xdebug.mode = develop,debug";
            echo "xdebug.start_with_request = yes";
        } >> /etc/php7/conf.d/xdebug.ini
    fi
    unset xdebug_major_version

    zypper -n install vim vim-data wget mc iputils curl less bind-utils
    wget -O phive.phar https://phar.io/releases/phive.phar
    wget -O phive.phar.asc https://phar.io/releases/phive.phar.asc
#    gpg --keyserver hkps://keys.openpgp.org --recv-keys 0x9D8A98B29B2D5D79
#    gpg --verify phive.phar.asc phive.phar
    chmod +x phive.phar
    mv phive.phar /usr/local/bin/phive
    ## Unit Tester
    phive install -g --trust-gpg-keys 4AA394086372C20A --copy phpunit
    ## Statical analyzer
    phive install -g --trust-gpg-keys CF1A108D0E7AE720 --copy phpstan
    ## Coding Standards
    phive install -g --trust-gpg-keys E82B2FB314E9906E --copy php-cs-fixer
    ## phar builder
    phive install -g --trust-gpg-keys 2DF45277AEF09A2F --copy humbug/box
    ## horde-components manual build
    wget https://horde-satis.maintaina.com/horde-components -O /usr/local/bin/horde-components ; chmod +x /usr/local/bin/horde-components

    echo "ending installation of developer-tools"
else
    echo "developer-mode is disabled: no installation of dev-tools"
fi


## copy files from /srv/original_config/apps to config dirs
/usr/local/bin/copy-original-configs

# TODO: remove this section, docker-compose >= 1.26 supports quotes in .env
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

if [[ -n $GITHUB_COMPOSER_TOKEN ]]; then
    echo "Configuring authentication to Github API for composer"
    composer --no-interaction config -g github-oauth.github.com "$GITHUB_COMPOSER_TOKEN"
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

## Optimize autoloader for production mode, but not in developer mode.
if [[ -v ENABLE_DEVELOPER_MODE && -n "$ENABLE_DEVELOPER_MODE" && $ENABLE_DEVELOPER_MODE == "yes" ]]; then
    /usr/local/bin/composer dump-autoload -d /srv/www/horde
else 
    ## Consider if we want to be even faster but less flexible and run -a and --apcu
    /usr/local/bin/composer dump-autoload -o -d /srv/www/horde/
fi

## TODO: BACKGROUND THIS and everything besides making the main process pid 1
## Wait for DB connection to succeed
## TODO: Make this optional for No-DB scenarios
if [[ -n "$MYSQL_PASSWORD" ]]; then
    echo "SHOW DATABASES" >/root/conntest.sql
    echo "WAITING FOR DB CONNECTION TO SUCCEED"
    echo "For new setups, this may take some time. You may see error messages"
    until php /srv/www/horde/vendor/bin/horde-sql-shell /root/conntest.sql &>/dev/null; do
        sleep 3
        echo "RETRYING"
    done
    echo "CONNECTION ESTABLISHED"
fi

## Run migrations N times
if [[ -v HORDE_MIGRATION_RUNS ]]; then
    for ((i = 1; i <= HORDE_MIGRATION_RUNS; i++)); do
        echo "Running Horde Schema Migrations: #$i"
        php /srv/www/horde/vendor/bin/horde-db-migrate
    done
fi

## if hordectl is installed and /srv/original_config/hordectl exists, run all yml files through it
/usr/local/bin/run-hordectl

# Inject initial user or change his password if he already exists
if [[ -v HORDE_ADMIN_USER ]]; then
    echo "Injecting Admin User $HORDE_ADMIN_USER"
    php /srv/www/horde/vendor/bin/hordectl patch user "$HORDE_ADMIN_USER" "$HORDE_ADMIN_PASSWORD"
fi

# if CUSTOM_TOOLS is not empty try to install them
if [[ -v CUSTOM_TOOLS && -n "$CUSTOM_TOOLS" ]]; then
    echo "Custom tools to be installed: $CUSTOM_TOOLS"
    zypper -n install "$CUSTOM_TOOLS"
fi

echo "Handing over to pid 1 command"
exec "$@"
