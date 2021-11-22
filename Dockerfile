FROM ubuntu:focal

MAINTAINER "Logan Wood" <logan@loganwood.xyz>

EXPOSE 25 587 465

VOLUME ["/var/log", "/var/spool/postfix"]

RUN apt update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y mailutils python3-pip python3 postfix git libsasl2-modules

RUN python3 -m pip install git+https://github.com/loganwoodxyz/chaperone.git

RUN mkdir -p /etc/chaperone.d
COPY chaperone.conf /etc/chaperone.d/chaperone.conf

COPY docker-setup.sh /docker-setup.sh
RUN chmod +x /docker-setup.sh

ENTRYPOINT ["/usr/local/bin/chaperone"]
