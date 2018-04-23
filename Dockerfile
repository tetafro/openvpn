FROM ubuntu:16.04
LABEL maintainer="Denis Krivak"

RUN apt update && \
    apt install -y curl openssl openvpn iptables

COPY run.sh /usr/local/bin/vpn
COPY client.conf server.conf /tpl/

VOLUME /etc/openvpn

EXPOSE 1194/udp

CMD ["vpn"]
