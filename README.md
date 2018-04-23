# Docker OpenVPN

OpenVPN with a simple init process inside docker container.

## Server

Make directory for OpenVPN configs. Start docker container and
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
    tetafro/openvpn
```

## Client

`vpn/client.conf`, generated on a previous step, is a full config with
key, certificate and external address. Just take it to your client machine
and run with a client app.

Ubuntu example:

```sh
sudo apt install openvpn
sudo openvpn --config client.conf
```
