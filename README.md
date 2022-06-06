# Docker OpenVPN

[![Release](https://img.shields.io/github/tag/tetafro/openvpn.svg)](https://github.com/tetafro/openvpn/releases)

OpenVPN with a simple init process inside a docker container.

## Server

Make a directory for OpenVPN configs. Start a docker container and
mount configs directory as a volume.

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

## Client

`vpn/client.conf`, generated on a previous step, is a full config with
key, certificate and external address. Just take it to your client machine
and run with a client app.

Ubuntu example:

```sh
scp your-vpn-server:/home/user/vpn/client.conf .
sudo apt install openvpn openvpn-systemd-resolved
sudo openvpn --config client.conf
```

---

[Original project](https://github.com/jpetazzo/dockvpn)
