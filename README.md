# Docker OpenVPN

[![Release](https://img.shields.io/github/tag/tetafro/openvpn.svg)](https://github.com/tetafro/openvpn/releases)

OpenVPN with a simple init process inside a docker container.

## Server

Make a directory for OpenVPN configs. Start a docker container and mount
configs directory as a volume.

```sh
mkdir vpn
cd vpn
docker run --detach \
    --privileged \
    --restart unless-stopped \
    --publish 1194:1194/udp \
    --volume $(pwd):/etc/openvpn \
    --name openvpn \
    ghcr.io/tetafro/openvpn
```

## Clients

Generate a new client config file (you can generate as many as you want):

```sh
docker exec -it openvpn /vpn/vpn.sh add-client
```

`vpn/client_N.conf`, generated on the previous step, is a full config with
key, certificate and external address. Just take it to your client machine
and run with a client app.

Ubuntu example:

```sh
scp your-vpn-server:/home/user/vpn/client.conf .
sudo apt install openvpn openvpn-systemd-resolved
sudo openvpn --config client.conf
```

## Development

```sh
docker build -t localhost/openvpn .
docker run --rm -it \
    --privileged \
    --publish 1194:1194/udp \
    --volume $(pwd)/conf:/etc/openvpn \
    --name openvpn \
    localhost/openvpn
docker exec -it openvpn /vpn/vpn.sh add-client
```

---

[Original project](https://github.com/jpetazzo/dockvpn)
