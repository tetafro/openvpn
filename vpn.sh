#!/bin/bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "USAGE: $0 [run-server|add-client]"
    exit 1
fi
cmd=$1

function init_server {
    mkdir -p /dev/net
    if [ ! -c /dev/net/tun ]; then
        mknod /dev/net/tun c 10 200
    fi

    echo 'Generating CA...'
    openssl req -new -x509 \
        -nodes \
        -days 3650 \
        -config /vpn/openssl_ca.conf \
        -keyout ca.key \
        -out ca.crt
    chmod 600 ca.key

    echo 'Generating Diffie-Hellman parameters...'
    openssl dhparam -out dh.pem 2048

    echo 'Generating server certificate...'
    openssl req -new \
        -nodes \
        -config /vpn/openssl_node.conf \
        -keyout server.key \
        -out server.csr
    openssl x509 -req \
        -CA ca.crt \
        -CAkey ca.key \
        -CAcreateserial \
        -extfile /vpn/openssl_node.conf \
        -extensions ca_ext \
        -in server.csr \
        -days 3650 \
        -out server.crt

    cp /vpn/openvpn_server.conf server.conf
}

function init_client {
    addr=$(curl -s http://myip.enix.org/REMOTE_ADDR)
    if [ -z "$addr" ]; then
        echo 'Failed to get public IP address'
        exit 1
    fi

    echo 'Generating client certificate...'
    openssl req -new \
        -nodes \
        -config /vpn/openssl_node.conf \
        -keyout client.key \
        -out client.csr
    openssl x509 -req \
        -CA ca.crt \
        -CAkey ca.key \
        -CAcreateserial \
        -extfile /vpn/openssl_node.conf \
        -extensions ca_ext \
        -in client.csr \
        -days 3650 \
        -out client.crt

    key="$(cat client.key)"
    cert="$(cat client.crt)"
    ca="$(cat ca.crt)"
    dh="$(cat dh.pem)"
    count=$(find . -name 'client*.conf' | wc -l)
    count=$((count+1))
    eval "echo \"$(cat /vpn/openvpn_client.conf)\"" > "client_${count}.conf"
    echo "New client config file: client_${count}.conf"

    # Cleanup
    rm -f client.csr client.crt client.key
}

cd /etc/openvpn
case $cmd in
    run-server )
        # Init on first run
        if [ ! -f server.crt ]; then
            init_server
        fi
        iptables -t nat -A POSTROUTING -s 192.168.23.0/24 -o eth0 -j MASQUERADE
        openvpn server.conf
    ;;
    add-client )
        init_client
    ;;
    *)
        echo 'Unknown command'
        exit 1
    ;;
esac
