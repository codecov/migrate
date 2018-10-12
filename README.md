### Codecov Migration 4.3.10 => 4.4.0

```
bash <(curl -s https://raw.githubusercontent.com/codecov/migrate/master/run)
```
> One-liner for `docker-compose` customers/


### Caveats

The run script assumes that certain ports will be available on localhost: 5001. 5009, and 5010.

### Containers

migrate: 

  * Moves assets from archive directory to another archive directory in a way that minio can read.
  * Also gzips archives and creates a registry of the files
  * This reduces volume size overall and makes it compatible with new version of codecov
  * Also goes to database and pulls reports out of db, saves in archive, and gzips. We scale workers on this process since its time consuming. Writes results to a separate table.
  
pg9:

  * runs pg dump from the same database version. 

pg10:

  * runs the pg10 restore to restore the old data. 
  
Data gets shared and passed around in a volume.
