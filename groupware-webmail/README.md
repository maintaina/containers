# groupware-webmail container

A container image founded on the "groupware" and "base" containers.

Flavours:
- containers/groupware-webmail:latest-runtime on openSUSE 15.3 and PHP 7.4
- containers/groupware-webmail:latest-apache the same, but running an Apache2 after bootstrap
- containers/groupware-webmail81:latest-runtime on openSUSE Tumbleweed and PHP 8.1
- containers/groupware-webmail81:latest-apache the same, but running an Apache2 after bootstrap

Images with a PHP-FPM daemon are not yet provided.

The image uses Composer 2, installed as shown on [Composer's installation documentation](https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md).

The repository contains a Github Actions workflow to automatically build the container image. The workflow is triggered when changes are pushed to the repository.

## How to Use the Image

The image is mainly built as the basis for a turnkey horde groupware+webmail installation with a standin IMAP and SMTP service container. This ready to run docker-compose setup is available at https://github.com/maintaina/deployments in the groupware-mail folder.

To build a another image on top of this one, use the following in your `Dockerfile`:
```Docker
FROM ghcr.io/maintaina/containers/groupware-webmail:latest-apache
```

To start a container based on this image, run:
```bash
docker run -it --name my-horde-container ghcr.io/maintaina/containers/groupware-webmail:latest-apache
```

The image is stored as a public image in Github's ghcr.io Container Registry. It can
be pulled without logging into the registry.

##  Entrypoint Magic

- See Supported Config Variables for basic configuration
- If a directory /srv/original_configs/hordectl exists, all contained yml files are applied in alphabetical order
- If a directory /srv/original_configs/apps/$app exists, contents will be copied to an app's $config dir. Existing files will not be overwritten.
  The same files will also be copied to the presets/ directory.
  You can re-run this any time using the /usr/local/bin/copy-original-configs script.

If you have custom logic that adds content late in the bootstrapping process or over the lifetime of the container, run the ```omposer horde-reconfigure``` command to fix up any linking into the ephemeral /srv/www/horde/web/ area. Any content directly deployed to this location will be lost on every install, upgrade or deletion of dependencies.

## Developer tools

- See the .env file of the horde-deployment repo.
- Once the ENABLE_DEVELOPER_MODE is set to yes (default is no), the entrypoint script will install these tools before bootstrapping the apache webserver:
	+ vim
	+ midnight-commander
	+ curl
	+ wget
	+ less
	+ php-debug (for php-7 and php-8)
	+ bind-utils (like dig)
	+ ip-utils (like ping)

- For installation of other tools use **CUSTOM_TOOLS**, for example **CUSTOM_TOOLS=neofetch** (note: correct names for installation can be found on the [opensuse repositiories](https://software.opensuse.org/))

- For more suggestions please report in an issue

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

### HORDE_ADMIN_USER and HORDE_ADMIN_PASSWORD

This will inject a user and password into the authentication backend. If the user already exists, his password will be changed (if possible).
The $conf['auth']['admin'] setting will not be changed. A default installation will assume the administrative account is called "administrator"


## Further information

### Variants

- php cli runtime only
- with apache webserver and mod_php
- with php-fpm

### Example deployments
