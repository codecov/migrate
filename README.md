### Codecov Migration 4.3.10 => 4.4.0

```
bash <(curl -s https://raw.githubusercontent.com/codecov/migrate/master/run)
```
> One-liner for `docker-compose` customers/

If the company **does not** use postgres via docker-compose (eg. AWS RDS) then they must follow the directions below.

1. Create a new, empty, database: postgres 9.6+ (preferably latest version possible, pg10)
1. Include the database dsn during script execution:

```
DATABASE_OLD_URL=postgres://... DATABASE_NEW_URL=postgres://... bash <(curl -s https://raw.githubusercontent.com/codecov/migrate/master/run)
```
> This way the external databases are used during migration.

# Steps

> The following steps are derived from the [`./run`](https://github.com/codecov/migrate/blob/master/run) script

1. Stop the current stack
1. Pull the migration compose
1. Start the migration compose
1. Scale up the `migrate` container
1. Wait for migrate to finish
1. Wait for database dump to finish
1. Wait for database restore to finish
1. Downs the migration stack
1. Loads the 4.4 stack
1. Up's the 4.4 stack

# Caveats

1. The run script assumes that certain ports will be available on localhost: 5001. 5009, and 5010.
1. Works **only** for customers using `docker-compose` deployment.

# Notes
1. Data gets shared and passed around in a volume.

# Containers

## migrate

1. Moves assets from archive directory to another archive directory in a way that minio can read. Gzips archives and creates a registry of the files

> This reduces volume size overall and makes it compatible with new version of codecov

2. Goes to database and pulls reports out of db, saves in archive, and gzips. We scale workers on this process since its time consuming. Writes results to a separate table.

## pg9

- runs pg dump from the same database version.

## pg10

- runs the pg10 restore to restore the old data.
