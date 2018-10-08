FROM          postgres:9.6-alpine

COPY          pg9/ /
COPY          server.py /

RUN           apk add python3 py3-pip
RUN           pip3 install flask

CMD           ["python3", "-m", "server"]
