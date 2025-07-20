FROM ubuntu:22.04
LABEL maintainer="Denis Krivak"

WORKDIR /etc/openvpn

RUN apt update && \
    apt install -y \
        openvpn=2.6.12-0ubuntu0.22.04.1 \
        curl \
        gettext-base \
        openssl \
        iptables && \
    mkdir -p /var/log/openvpn

COPY vpn.sh /vpn/
COPY openvpn_client.conf \
    openvpn_server.conf \
    openssl_ca.conf \
    openssl_node.conf \
    /vpn/

VOLUME /etc/openvpn

EXPOSE 1194/udp

CMD ["/vpn/vpn.sh", "run-server"]
