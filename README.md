# Docker OpenVPN

[![Release](https://img.shields.io/github/tag/tetafro/openvpn.svg)](https://github.com/tetafro/openvpn/releases)

OpenVPN with a simple init process inside a docker container.

1. [Server](#server)
2. [Clients](#clients)
    1. [Add](#add)
    2. [Connect](#connect)
    3. [Revoke](#revoke)
3. [Development](#development)

## Server

Make a directory for OpenVPN configs. Start a docker container and mount
configs directory as a volume.

```sh
mkdir vpn
docker run --detach \
    --privileged \
    --restart unless-stopped \
    --publish 1194:1194/udp \
    --volume $(pwd)/vpn:/etc/openvpn \
    --name openvpn \
    ghcr.io/tetafro/openvpn
```

## Clients

### Add

Generate a new client config file (you can generate as many as you want):

```sh
docker exec -it openvpn add-client [NAME] [TTL_DAYS]
```

### Connect

The above command will generate `vpn/clients/NAME.conf` file (in the mounted
directory that we created above), which is a full config with a private key and
certificates. Just take it to your client machine and run with your client app.

Ubuntu example:

```sh
sudo apt install openvpn
sudo openvpn --config client.conf
```

### Revoke

Note that clients configs need to be stored on the server to be able to revoke
them.

```sh
docker exec -it openvpn revoke-client [NAME]
```

## Development

```sh
docker build -t localhost/openvpn .
mkdir -p conf
docker run --rm -it \
    --privileged \
    --publish 1194:1194/udp \
    --volume $(pwd)/conf:/etc/openvpn \
    --name openvpn \
    localhost/openvpn
docker exec -it openvpn add-client bob 10
```

---

[Original project](https://github.com/jpetazzo/dockvpn)
