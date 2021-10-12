# Containers

This repository maintains several container images useful to deploy *developer versions* of Horde Framework or Horde Groupware.
These image builds are based on the openSUSE distribution's official container images.

Currently, the base image is openSUSE LEAP 15.3

## base

A horde environment with no extra apps installed

Flavors:
 - runtime
 - apache2
 - fpm (tbd)

## groupware

A horde environment with password changing app (passwd), tasks (nag), addressbook (turba), calendar (kronolith), notes (mnemo)

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
