#!/bin/bash


## Build the base image as pure runtime without Apache or FPM in two versions

docker build --target base-runtime-74 . --tag local-base-74-runtime:latest
docker build --target base-runtime-81 . --tag local-base-81-runtime:latest

## Build the developer base runtime

## Build the developer groupware-webmail runtime

## Build the groupware (without webmail) runtime from the base runtime

## Build the groupware-webmail runtime from the base runtime

