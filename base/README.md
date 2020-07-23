# horde-composer-docker

A container image based on openSUSE Tumbleweed with the Composer-based Horde deployment from [maintaina-com/horde-deployment](https://github.com/maintaina-com/horde-deployment).
The image does not contain a web server.

The repository contains a Github Actions workflow to automatically build the container image. The workflow is triggered when changes are pushed to the repository.

## How to Use the Image

To build a another image on top of this one, use the following in your `Dockerfile`:
```Docker
FROM docker.pkg.github.com/maintaina/containers/base:latest
```

To start a container based on this image, run:
```bash
docker run -it --name my-horde-container docker.pkg.github.com/maintaina/containers/base:latest
```

You may need to be logged into the Github Docker Registry to pull the image, even if it's a public image.

https://help.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-docker-for-use-with-github-packages

## Further information

### Variants

- php cli runtime only
- with apache webserver and mod_php
- with php-fpm

### Example deployments
