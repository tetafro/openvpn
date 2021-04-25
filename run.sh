#!/bin/sh
set -e

cd /etc/openvpn

# Init on first run
if [ ! -f /key.pem ]; then
    mkdir -p /dev/net
    if [ ! -c /dev/net/tun ]; then
        mknod /dev/net/tun c 10 200
    fi

    openssl dhparam -out dh.pem 2048
    openssl genrsa -out key.pem 2048
    chmod 600 key.pem
    openssl req -new -key key.pem -out csr.pem -subj /CN=OpenVPN/
    openssl x509 -req -in csr.pem -out cert.pem -signkey key.pem -days 24855

    cp /tpl/server.conf server.conf
fi

# Generate client config if not exists
if [ ! -f /key.pem ]; then
    ADDR=$(curl -s http://myip.enix.org/REMOTE_ADDR)
    if [ -z "$ADDR" ]; then
        echo "Failed to get public IP address"
        exit 1
    fi
    KEY="$(cat key.pem)" \
    CERT="$(cat cert.pem)" \
    DH="$(cat dh.pem)" \
    eval "echo \"$(cat /tpl/client.conf)\"" > client.conf
fi

iptables -t nat -A POSTROUTING -s 192.168.23.0/24 -o eth0 -j MASQUERADE

openvpn server.conf
