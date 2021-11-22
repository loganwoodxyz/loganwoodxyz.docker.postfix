FROM ubuntu:focal

MAINTAINER "Logan Wood" <logan@loganwood.xyz>

EXPOSE 25

VOLUME ["/var/log", "/var/spool/postfix"]


RUN apt update && \
apt install -y python3 postfix libsasl2-modules

RUN python3 -m pip install chaperone

RUN mkdir -p /etc/chaperone.d
COPY chaperone.conf /etc/chaperone.d/chaperone.conf

COPY docker-setup.sh /docker-setup.sh
RUN chmod +x /docker-setup.sh

ENTRYPOINT ["/usr/local/bin/chaperone"]
