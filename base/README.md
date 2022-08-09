# horde-composer-docker

A container image based on openSUSE Leap with the Composer-based Horde deployment from [maintaina-com/horde-deployment](https://github.com/maintaina-com/horde-deployment).
The image does not contain a web server.

The image uses Composer 2, installed as shown on [Composer's installation documentation](https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md).

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

- See the .env file
- Once the ENABLE_DEVELOPER_MODE is set to yes (default is no), the following tools will be pre-installed into the -web container:
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

- base:latest-runtime php cli runtime only, openSUSE Leap 15.3 with PHP 7.4
- base81:latest-runtime php cli runtime only, openSUSE Tumbleweed with PHP 8.1
- base:latest-apache is base:latest-runtime with apache webserver and mod_php
- base81:latest-apache is base81:latest-runtime with apache webserver and mod_php
- with php-fpm TBD

### Example deployments
