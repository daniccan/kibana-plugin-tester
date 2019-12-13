FROM ubuntu:18.04

LABEL maintainer "https://github.com/daniccan"

RUN apt-get update \
    && apt-get install -y openjdk-8-jdk \
        wget \
        curl \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 ubuntu
USER ubuntu

WORKDIR /home/ubuntu

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64

COPY ./entrypoint.sh /home/ubuntu/entrypoint.sh

CMD ./entrypoint.sh