FROM          postgres:9.3-alpine

COPY          backup/ /
COPY          server.py /

RUN           apk add python3 py3-pip zip pv
RUN           pip3 install flask

VOLUME        ["/archive-backup"]

CMD           ["python3", "-m", "server"]


