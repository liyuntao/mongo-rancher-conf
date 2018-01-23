FROM alpine:3.1
MAINTAINER Hussein Galal

# install giddyup
RUN mkdir -p /opt/rancher/bin
COPY ./giddyup /opt/rancher/bin/
COPY ./*.sh /opt/rancher/bin/
RUN chmod u+x /opt/rancher/bin/*

VOLUME /opt/rancher/bin
