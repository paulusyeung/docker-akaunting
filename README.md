# gslime/akaunting

- [Introduction](#introduction)
  - [Contributing](#contributing)
  - [Issues](#issues)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Persistence](#persistence)
  - [ACME certs](#acme-certs)
- [Maintenance](#maintenance)
  - [Creating backups](#creating-backups)
  - [Restoring backups](#restoring-backups)
  - [Upgrading](#upgrading)
  - [Shell Access](#shell-access)

# Introduction

`Dockerfile` to create a [Docker](https://www.docker.com/) container image for [Akaunting](https://akaunting.com/).

Akaunting is a self-hosted open source accounting software.

This is based heavily on the [sameersbn/docker-akaunting](https://github.com/sameersbn/docker-akaunting) repository.
The first key difference is that I've modified it to be based on Alpine rather than Ubuntu.
The second key difference is that the Akaunting software is not actually contained in the image, rather it is bootstraped
by downloading it into a writable volume the first time that the the image is run. This allows the built in updating
feature of Akaunting to work even though it is running in a container.

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your awesome features and bug fixes
- Help users resolve their [issues](../../issues?q=is%3Aopen+is%3Aissue).
- Support the development of this image with a [donation](http://www.damagehead.com/donate/)

## Issues

Before reporting your issue please try updating Docker to the latest version and check if it resolves the issue. Refer to the Docker [installation guide](https://docs.docker.com/installation) for instructions.

SELinux users should try disabling SELinux using the command `setenforce 0` to see if it resolves the issue.

If the above recommendations do not help then [report your issue](../../issues/new) along with the following information:

- Output of the `docker version` and `docker info` commands
- The `docker run` command or `docker-compose.yml` used to start the image. Mask out the sensitive bits.
- Please state if you are using [Boot2Docker](http://www.boot2docker.io), [VirtualBox](https://www.virtualbox.org), etc.

# Getting started

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/gslime/akaunting) and is the recommended method of installation.

```bash
docker pull gslime/akaunting
```

Alternatively you can build the image yourself.

```bash
docker build -t gslime/akaunting github.com/kll/docker-akaunting-alpine
```

## Quickstart

The quickest way to start using this image is with [docker-compose](https://docs.docker.com/compose/).

Clone the repository.

```bash
git clone https://github.com/kll/docker-akaunting-alpine.git
```

Copy the `example.env` file to `.env` and then configure the settings.
Set the `AKAUNTING_URL` value with the url from which Akaunting will be externally accessible.

Create the required named docker volumes.

```bash
docker volume create akaunting_db
docker volume create akaunting_www
docker volume create akaunting_data
```

Then bring everything up with docker-compose.

```bash
docker-compose up --build
```

## Persistence

Persistence is achieved through docker volumes. They are created externally from the `docker-compose` file so they can
be given sensible names for easy identification later. By default they will be located under the `/var/lib/docker/volumes`
folder on your file system. 

> *The [Quickstart](#quickstart) instructions cover creating the appropriate volumes.*

## ACME certs

If you already have a working Traefik reverse proxy setup, then you can connect this to it by copying the
`docker-compose.override.example.yml` file to `docker-compose.override.yml` and editing it as appropriate.
Installing and configuring Traefik itself is out of the scope of this repository.

# Maintenance

## Creating backups

The image allows users to create backups of the Akaunting installation using the `app:backup:create` command or the `akaunting-backup-create` helper script. The generated backup consists of configuration files, uploaded files and the sql database.

Before generating a backup — stop and remove the running instance.

```bash
docker stop akaunting && docker rm akaunting
```

Relaunch the container with the `app:backup:create` argument.

```bash
docker run --name akaunting -it --rm [OPTIONS] \
  gslime/akaunting:latest app:backup:create
```

The backup will be created in the `backups/` folder of the [Persistent](#persistence) volume. You can change the location using the `AKAUNTING_BACKUPS_DIR` configuration parameter.

> **NOTE**
>
> Backups can also be generated on a running instance using:
>
>  ```bash
>  docker exec -it akaunting akaunting-backup-create
>  ```

By default backups are held indefinitely. Using the `AKAUNTING_BACKUPS_EXPIRY` parameter you can configure how long (in seconds) you wish to keep the backups. For example, setting `AKAUNTING_BACKUPS_EXPIRY=604800` will remove backups that are older than 7 days. Old backups are only removed when creating a new backup, never automatically.

## Restoring Backups

Backups created using instructions from the [Creating backups](#creating-backups) section can be restored using the `app:backup:restore` argument.

Before restoring a backup — stop and remove the running instance.

```bash
docker stop akaunting && docker rm akaunting
```

Relaunch the container with the `app:backup:restore` argument. Ensure you launch the container in the interactive mode `-it`.

```bash
docker run --name akaunting -it --rm [OPTIONS] \
  gslime/akaunting:latest app:backup:restore
```

A list of existing backups will be displayed. Select a backup you wish to restore.

To avoid this interaction you can specify the backup filename using the `BACKUP` argument to `app:backup:restore`, eg.

```bash
docker run --name akaunting -it --rm [OPTIONS] \
  gslime/akaunting:latest app:backup:restore BACKUP=1417624827_akaunting_backup.tar
```

## Upgrading

To upgrade to newer releases, use the built in [One-Click Update feature](https://akaunting.com/docs/update).

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker-compose exec -it akaunting bash
```
