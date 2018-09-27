# -*- coding: utf-8 -*-

import os
import socket
import psycopg2
from psycopg2.extensions import parse_dsn
import pytest
import docker as Docker

docker = Docker.from_env()

db = psycopg2.connect(
    **parse_dsn(os.getenv('DATABASE_URL'))
)


@pytest.fixture
def setup():
    # insert an owner, repo, commit
    cur = db.cursor()
    cur.execute('drop schema public cascade;')
    cur.execute('create schema public;')
    cur.execute("create type commit_state as enum('complete', 'error');")
    cur.execute('create table owners (service text, ownerid int primary key);')
    cur.execute('create table repos (service_id text, repoid int primary key, ownerid int references owners, deleted boolean);')
    cur.execute("create table commits (commitid text, repoid int references repos, chunks text, deleted boolean, state commit_state);")
    cur.execute("insert into owners values ('github', 1);")
    cur.execute("insert into repos values ('123', 1, 1, false);")
    cur.execute("insert into repos values ('789', 2, 1, false);")
    cur.execute("insert into commits values ('shawithchunks', 1, 'foobar', false, 'complete');")
    cur.execute("insert into commits values ('shawithoutchunks', 2, null, false, 'complete');")


def test_migrate(setup, tmpdir):
    # cannot get it to connect to my local database. ugh.
    return

    res = docker.containers.run(
        image='codecov/migrate',
        command='python -m scripts.migrate',
        environment={
            'DATABASE_URL': os.getenv('DATABASE_URL')
        },
        volumes={
            str(tmpdir): {'bind': '/archive', 'mode': 'rw'},
        },
        auto_remove=True
    )

    cur = db.cursor()
    output = res.decode('utf-8')
    print(output)
    assert '=> repoid=1 commitid=shawithchunks' in res
    assert 'commitid=shawithoutchunks' not in res
    assert 'No more data found! Finished' in res
    assert tmpdir.join('.minio.sys/buckets/archive/v4/repos/4C572972CDB9B12D60EA5BAF9E1D7CBA/commits/shawithchunks/chunks.txt/fs.json').check(file=1)
    assert tmpdir.join('archive/v4/repos/4C572972CDB9B12D60EA5BAF9E1D7CBA/commits/shawithchunks/chunks.txt').check(file=1)
    cur.execute('SELECT working, complete from migrate_range;')
    assert cur.fetchall() == [(False, True)]
    cur.execute('SELECT repoid, commitid from migrate_range;')
    assert cur.fetchall() == [(1, 'shawithchunks')]
