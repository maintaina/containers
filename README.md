# Containers

This repository maintains several container images useful to deploy *developer versions* of Horde Framework or Horde Groupware.
These image builds are based on the openSUSE distribution's official container images.

The images built from this branch are based on openSUSE Tumbleweed and PHP version 8.0. Their tags contain `php80-` instead of `latest-`. If you are looking for PHP 7, go to the master branch and/or use the images with `latest-` in their tags.

## base

A horde environment with no extra apps installed

Flavors:
 - runtime
 - apache2
 - fpm (tbd)

## groupware

A horde environment with password changing app (passwd), tasks (nag), addressbook (turba), calendar (kronolith), notes (mnemo) and the content application.

Flavors:
 - runtime
 - apache2
 - fpm (tbd)


## groupware-webmail

Like groupware, but added webmail (imp) and mail filters (ingo)

Flavors:
 - runtime
 - apache2
 - fpm (tbd)
