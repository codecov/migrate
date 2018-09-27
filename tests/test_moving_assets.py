# -*- coding: utf-8 -*-

import os
import docker as Docker

docker = Docker.from_env()


def write(data, path):
    os.makedirs(os.path.dirname(path))
    with open(path, 'w+') as f:
        f.write(data)


def test_assets_move(tmpdir):
    for x in range(0, 10):
        write('foobar', f'{tmpdir}/v4/folder/{x}/chunks.txt')

    res = docker.containers.run(
        image='codecov/migrate',
        command='scripts/move_archive_assets.sh',
        auto_remove=True,
        volumes={
            str(tmpdir): {'bind': '/archive', 'mode': 'rw'}
        }
    )

    output = res.decode('utf-8')
    assert 'Compressing 10 reports' in output
    assert tmpdir.join('.minio.sys/format.json').check(file=1)
    assert tmpdir.join('.minio.sys/buckets/archive/policy.json').check(file=1)
    assert tmpdir.join('.minio.sys/buckets/archive/v4/folder/0/chunks.txt/fs.json').check(file=1)
    assert tmpdir.join('archive/v4/folder/0/chunks.txt').check(file=1)
    assert tmpdir.join('v4/folder/0/chunks.txt').check(exists=0)


def test_stuff_moved_already(tmpdir):
    tmpdir.mkdir('.minio.sys').join('format.json').write('foobar')

    res = docker.containers.run(
        image='codecov/migrate',
        command='scripts/move_archive_assets.sh',
        auto_remove=True,
        volumes={
            str(tmpdir): {'bind': '/archive', 'mode': 'rw'}
        }
    )

    assert 'Archive migration already completed.' in res.decode('utf-8')
