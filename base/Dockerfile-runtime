FROM docker.io/opensuse/tumbleweed:latest

# installs required packages git, composer, unzip and php extensions
# then cleans up zypper cache
# then creates the target directory for horde and clones the deployment
RUN zypper --non-interactive install --no-recommends --no-confirm \
    git-core \
    gzip \
    php-composer \
    php7 \
    php7-bcmath \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-gd \
    php7-gettext \
    php7-iconv \
    php7-imagick \
    php7-json \
    php7-ldap \
    php7-mbstring \
    php7-mysql \
    php7-opcache \
    php7-openssl \
    php7-pcntl \
    php7-pdo \
    php7-pear \
    php7-phar \
    php7-posix \
    php7-redis \
    php7-sockets \
    php7-sqlite \
    php7-tokenizer \
    php7-xmlrpc \
    php7-xmlwriter \
    tar \
    unzip \
    && zypper clean -a \
    && mkdir -p /srv/www/horde \
    && git clone https://github.com/maintaina-com/horde-deployment /srv/www/horde

# set working directory for all subsequent steps (and images derived from this one)
WORKDIR /srv/www/horde

# install php dependencies with composer and remove cache afterwards
RUN composer install -n && rm -rf /root/.composer/cache

CMD ["/bin/bash"]
