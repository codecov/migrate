FROM          postgres:10.5-alpine

COPY          pg10/ /
COPY          server.py /

RUN           apk add python3 py3-pip
RUN           pip3 install flask

CMD           ["python3", "-m", "server"]
