# Containers

This repository maintains several container images useful to deploy *developer versions* of Horde Framework or Horde Groupware.
These image builds are based on the openSUSE distribution's official container images.

Currently, the base image is openSUSE LEAP 15.3 for the normal flavour and Beta images with Tumbleweed and PHP 8 are built separately.
At some point, the PHP 7.4 container builds may be dropped.

## base

A horde environment with no extra apps installed.

Flavors:
 - runtime
 - apache
 - runtime81
 - apache81
 - fpm (tbd)

## groupware

A horde environment with password changing app (passwd), tasks (nag), addressbook (turba), calendar (kronolith), notes (mnemo) and the content application.

Flavors:
 - runtime
 - apache
 - runtime81
 - apache81
 - fpm (tbd)

## groupware-webmail

Like groupware, but added webmail (imp) and mail filters (ingo).

Flavors:
 - runtime
 - apache
 - runtime81
 - apache81
 - fpm (tbd)
