# Codecov v4.3.9 => 4.4.0 Migration Guide

This guide is meant to assist with migrating a Codecov Enterprise v4.3.9 install to v4.4.0. It is specifically tailored to users who are utilizing the standard Dockerized deployment. However the code is open source and descriptions will be provided such that enterprise users taking advantage of non-standard setups can understand how to migrate themselves.

The full migration process is open source and stored within this repository. If you'd like to dig deeper to understand exactly what the migration is doing, you can review this repository in full. 

Additionally, codecov is here to help! If you'd like to discuss migrating beforehand, or need help with the process, please reach out to us at: support@codecov.io with the Subject Line "Enterprise Migration Assistance Needed".

## What's in this repository?

This repository is comprised of two major components

1. Scripts to provide a highly automated upgrade path for those that utilize a standard Dockerized install of Codecov Enterprise.
2. Source code and text to support those users who wish to upgrade and don't have a standard Dockerized install of Codecov Enterprise (e.g., Kubernetes)

If you feel like you fit into some other category but still wish to upgrade, please contact us!

### How do I know if my install is "standard"?

If the original implementer of Codecov at your company used [Docker install instructions](https://docs.codecov.io/docs/deploying-with-docker) in Codecov's documentation, it's likely your install is standard. Put more specifically:

1. `docker-compose up` starts codecov enterprise
2. Your docker-compose.yml file is unmodified
3. No significant changes have been made to the nginx configuration of Codecov Enterprise. 

If you need to compare your install to Codecov Enterprise's default, you can always compare the [docker-compose.yml](https://raw.githubusercontent.com/codecov/enterprise/master/compose-assets/docker-compose.yml) and [nginx.config](https://raw.githubusercontent.com/codecov/enterprise/master/compose-assets/nginx.config) files to look for any major changes.

If your setup varies from the standard Docker install, please contact us at support@codecov.io to discuss other potential upgrade paths. 

## My Install uses Docker and is standard, what next?

First, **backup everything**. The migration scripts have a helper method to assist with backups, but if you already have your own process in place to generate database and file archive backups, make sure those backups are up to date and can be used to recover if necessary. 

You should backup the following:

* codecov.yml so no configuration is lost
* The `/archive` directory that stores uploaded reports
* The codecov enterprise database

If you don't have backups, you can run this migration script with the `-b` flag (see Running the Migration below). This will generate a compressed backup of your report archives and a data-only dump of your database that can be used to restore a fresh v4.3.9 install in the event of a total failure.

A successful migration will bring your install to Codecov Enterprise v.4.4.0 with all data intact, but proper backups will ensure there is always a way to recover from the worst of catastrophes.

## Running the migration

The migration itself is completely dockerized, you don't even need to clone this repository to run it. Simply curl the migration script into your codecov enterprise install directory, give it +x permissions, and run it from the command line. 

    cd /path/to/codecov/enterprise/install
    curl -fsSL https://raw.githubusercontent.com/codecov/migrate/master/run > migrate
    chmod +x migrate
    ./migrate # or ./migrate -b for backup generation
    
`./migrate` will: 

1. Take down your running infrastructure
2. Migrate the datatabase to postgres 10, while dropping some no longer needed columns
3. Convert the flat file report archive to a compressed archive backed by minio
4. Pull down a new docker-compose for v.4.4.0
5. Spin up and start Codecov Enterprise v4.4.0 

`./migrate -b` if chosen, will:

1. Compress `/archive` and save it to an externally mounted volume. By default this will be a `/backups` folder in your codecov-enterprise directory.
2. Do a data only dump of the postgres database and store it to a `/backups` folder.
3. Terminate without running the migration. You'll need to run `./migrate` separately to run the full migration after backing up. 

*NOTE: Depending on the size of your `/archive` directory and the number of reports it contains, backup will take awhile. On average the resulting compressed archive will be ~ 25% the size of the archive folder itself. So make sure you have enough space to store this backup*

## Caveats

1. The run script assumes that certain ports will be available on localhost: 5001, 5009, 5010, and 5011.
2. If you're upgrading from a trial of 4.3.9 to a trial of 4.4.0 for evaluation purposes, you will need to [include your enterprise license key in the codecov.yml file](https://docs.codecov.io/docs/configuration#section-enterprise-license) of 4.4.0 for codecov to function properly. If you don't have an enterprise license key for your trial, contact support@codecov.io

## Additional notes

### Migration Containers

The migration performs tasks by spinning up a few Docker containers and kicking off their operations using curl. You can review how this works in the `run` script in this repository. The general purpose of each container is described below:

#### migrate

1. Moves assets from archive directory to another archive directory in a way that minio can read. Gzips archives and creates a registry of the files

> This reduces volume size overall and makes it compatible with new version of codecov

2. Pulls database reports out of db, saves in archive, and gzips. Scaled workers are used on this process since it's time consuming. You can edit the size of this scale by editing the `run` script.

#### backup

Backs up the report archive and database to a `/backups` folder.

#### pg9

- runs `pg_dump` to export the database's current data

#### pg10

- runs the pg10 restore to restore the pg9 data to a new pg10 databse.

## 4.4.0 Major Changelog

1. The flat file archive has been replaced by minio, which is more secure and provides compression by default. This results in less space consumed on disk for Codecov's report archive. The access credentials for minio can be changed in the `docker-compose.yml` file (see `MINIO_ACCESS_KEY` and `MINIO_ACCESS_SECRET` variables).
2. The database has been upgraded from postgres 9.6 to postgres 10. 
3. The codebase is now more closely in alignment with Codecov's hosted offering (https://codecov.io), and as such can now experience faster and more frequent upgrade cycles.
4. nginx has been replaced by traefik, which allows for cleaner autodiscovery of services. This should provide a simpler route to service scaling if required. 
