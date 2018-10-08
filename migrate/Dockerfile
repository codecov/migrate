FROM          python:3.6.6

COPY          migrate/ /
COPY          server.py /

RUN           pip install psycopg2 flask
RUN           apt-get update
RUN           apt-get install -y openssl pv

CMD           ["/entry"]
