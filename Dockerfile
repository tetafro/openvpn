FROM ubuntu:24.04
LABEL maintainer="Denis Krivak"

WORKDIR /etc/openvpn

RUN apt update && \
    apt install -y \
        openvpn=2.6.14-0ubuntu0.24.04.1 \
        curl \
        gettext-base \
        openssl \
        iptables && \
    mkdir -p /var/log/openvpn \
        /etc/openvpn \
        /etc/openvpn-setup

COPY /scripts/vpn \
    /scripts/run-server \
    /scripts/add-client \
    /scripts/revoke-client \
    /usr/local/bin/
COPY openvpn/client.conf \
    openvpn/server.conf \
    openssl/ca.conf \
    openssl/req_ca.conf \
    openssl/req_server.conf \
    openssl/req_client.conf \
    /etc/openvpn-setup/

VOLUME /etc/openvpn
EXPOSE 5528/udp

CMD ["run-server"]
