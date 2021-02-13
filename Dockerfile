FROM python:alpine

MAINTAINER "Alex <ualex73@gmail.com>"

WORKDIR /usr/src/app

COPY app/* ./

RUN pip install --no-cache-dir -r requirements.txt && \
    mkdir /config

CMD [ "/bin/sh", "./run.sh" ]
