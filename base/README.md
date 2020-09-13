# horde-composer-docker

A container image based on openSUSE Tumbleweed with the Composer-based Horde deployment from [maintaina-com/horde-deployment](https://github.com/maintaina-com/horde-deployment).
The image does not contain a web server.

The repository contains a Github Actions workflow to automatically build the container image. The workflow is triggered when changes are pushed to the repository.

## How to Use the Image

To build a another image on top of this one, use the following in your `Dockerfile`:
```Docker
FROM ghcr.io/maintaina/containers/base:latest
```

To start a container based on this image, run:
```bash
docker run -it --name my-horde-container ghcr.io/maintaina/containers/base:latest
```

The image is stored as a public image in Github's new Container Registry. It can
be pulled without logging into the registry.

##  Entrypoint Magic

- See Supported Config Variables for basic configuration
- If a dir /srv/original_configs/hordectl exists, all contained yml files are applied in alphabetical order

## Supported Config Variables

### GITHUB_COMPOSER_TOKEN
This variable allows to inject a github token into composer globally. This may be required to circumvent API limits when installing additional content.

### MYSQL related variables

These are used by entrypoint to inject a mysql database connection into the config file template. 

MYSQL_PASSWORD
MYSQL_DATABASE
MYSQL_HOSTNAME
MYSQL_USER
MYSQL_PASSWORD

### HORDE_MIGRATION_RUNS

This governs if and how many times the entry point should run the horde migration script.


## Further information

### Variants

- php cli runtime only
- with apache webserver and mod_php
- with php-fpm

### Example deployments
