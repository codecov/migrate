FROM          python:3.6.6

COPY          . .

RUN           pip install psycopg2
RUN           apt-get update
RUN           apt-get install -y openssl pv

CMD           ["scripts/run"]
