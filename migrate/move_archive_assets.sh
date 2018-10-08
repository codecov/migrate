#!/bin/bash

set -e

######
# This script will move assets in the archive
# so they work with minio
######

# move into the archive volume
cd /archive/

mkdir -p .minio.sys/buckets/archive/

echo 'Before'
du -hcs v4/
echo ''

# create minio format
echo '{"version":"1","format":"fs","id":"226ee23d-34ae-4dd9-a0a5-11cd6033f058","fs":{"version":"2"}}' \
  > ./.minio.sys/format.json

# create bucket poliy
policy='{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":["*"]},"Action":["s3:GetBucketLocation"],"Resource":["arn:aws:s3:::archive"]},{"Effect":"Allow","Principal":{"AWS":["*"]},"Action":["s3:ListBucket"],"Resource":["arn:aws:s3:::archive"],"Condition":{"StringEquals":{"s3:prefix":["*"]}}},{"Effect":"Allow","Principal":{"AWS":["*"]},"Action":["s3:GetObject"],"Resource":["arn:aws:s3:::archive/**"]}]}'
echo "$policy" > ./.minio.sys/buckets/archive/policy.json

# old was mapped archive-volume:/archive
# so it's missing the "archive" bucket name
# this command will fail if it already exists
mkdir archive/
mv v4/ archive/

# copy all folder structures
fs='{"version":"1.0.2","checksum":{"algorithm":"","blocksize":0,"hashes":null},"meta":{"content-encoding":"gzip","content-type":"text/plain","etag":null,"expires":null}}'
total=$(find . -name 'chunks.txt' -type f | wc -l)
echo "Compressing $total reports..."
for file in $(find . -name 'chunks.txt' -type f 2> /dev/null);
do
  # make sure glob found a file
  [ -e "$file" ] || continue
  # compress
  gzip -nf "$file"
  # remove .gz from filename
  mv "$file.gz" "$file"
  # create fs folder
  mkdir -p "./.minio.sys/buckets/$file"
  # create fs.json
  echo "$fs" > "./.minio.sys/buckets/$file/fs.json"
  # for progress bar
  printf .
done | pv -ept -i0.2 -s$total -w 80 > /dev/null

echo 'After'
du -hcs archive/
