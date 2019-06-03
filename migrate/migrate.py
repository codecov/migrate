# -*- coding: utf-8 -*-

from base64 import b16encode
from hashlib import sha1, md5
from psycopg2.extensions import parse_dsn
from sys import stdout
import gzip
import os
import psycopg2
import signal
import sys


prefix = os.getenv('PREFIX', '')  # for testing only

def e(string):
    return string.encode('utf-8')


def get_archive_hash(row: list) -> str:
    _hash = md5()
    _hash.update(
        e(f'{row[0]}{row[2]}{row[3]}1bc45u9e1wd947f2a0681b215404873e'))
    return b16encode(_hash.digest())


def write_to_archive(path: str, data: str):
    os.makedirs(os.path.dirname(f'{prefix}/archive/archive/{path}'))
    # /volume/bucket/path
    with gzip.open(f'{prefix}/archive/archive/{path}', 'wb') as f:
        f.write(data)

    os.makedirs(os.path.dirname(f'{prefix}/archive/.minio.sys/buckets/archive/{path}/fs.json'))
    with open(f'{prefix}/archive/.minio.sys/buckets/archive/{path}/fs.json', 'w+') as meta:
        meta.write('{"version":"1.0.2","checksum":{"algorithm":"","blocksize":0,"hashes":null},"meta":{"content-encoding":"gzip","content-type":"text/plain","etag":null,"expires":null}}')


class GracefulKiller:
    kill_now = False
    def __init__(self):
        signal.signal(signal.SIGINT, self.exit_gracefully)
        signal.signal(signal.SIGTERM, self.exit_gracefully)

    def exit_gracefully(self,signum, frame):
        self.kill_now = True


def main():
    limit = os.getenv('LIMIT', 50)
    conn = psycopg2.connect(
        **parse_dsn(os.getenv('DATABASE_URL') or 'postgres://postgres@postgres:5432')
    )
    cur = conn.cursor()
    killer = GracefulKiller()

    try:
        cur.execute('CREATE TABLE migrate_range (id serial primary key, start int, stop int, working boolean default false, complete boolean default false);')
        cur.execute('INSERT INTO migrate_range (start, stop) select i, i+5 from generate_series(1, (select max(repoid) from repos limit 1), 5) as i;')
        cur.execute('CREATE TABLE migrated (repoid int not null, commitid text not null);')
        cur.execute('CREATE INDEX migrated_keys on migrated (repoid, commitid);')
    except psycopg2.ProgrammingError:
        # table already exists
        pass
    finally:
        conn.commit()

    while True:
        try:
            cur.execute(
                """UPDATE migrate_range
                   set working=true
                   where id=(SELECT id
                             from migrate_range
                             where not working
                               and not complete
                             limit 1)
                  returning id, start, stop;"""
            )
            range_res = cur.fetchone()
            conn.commit()

            if not range_res:
                print('No more data found! Finished')
                break

            while True:
                assert not killer.kill_now

                migrants = []

                cur.execute(
                    """SELECT c.repoid, c.commitid, o.service, r.service_id, c.chunks
                       from commits c
                       inner join repos r using (repoid)
                       inner join owners o using (ownerid)
                       where r.deleted is not true
                         and c.deleted is not true
                         and c.chunks is not null
                         and c.state = 'complete'::commit_state
                         and c.repoid between %s and %s
                         and not exists(select true from migrated m
                                        where repoid=c.repoid
                                          and commitid=c.commitid
                                        limit 1)
                       limit %s;""",
                    (range_res[1], range_res[2], limit)
                )

                for row in cur:
                    sys.stdout.write(f'=> repoid={row[0]} commitid={row[1]}\n')
                    migrants.append([row[0], row[1]])
                    write_to_archive(
                        path='/'.join((
                            'v4',
                            'repos',
                            get_archive_hash(row).decode('utf-8'),
                            'commits',
                            str(row[1]),
                            'chunks.txt'
                        )),
                        data='\n<<<<< end_of_chunk >>>>>\n'.join(row[4]).encode('utf-8')
                    )

                if not migrants:
                    break

                cur.executemany(
                    "INSERT INTO migrated (repoid, commitid) values (%s, %s);",
                    migrants
                )
                conn.commit()

        except Exception as e:
            cur.execute(
                "UPDATE migrate_range set working=false where id=%s;",
                (range_res[0], )
            )
            if not isinstance(e, AssertionError):
                raise


if __name__ == '__main__':
    main()
