# macOS VM in Docker

Runs macOS inside a container using QEMU/KVM, via the open-source
[sickcodes/Docker-OSX](https://github.com/sickcodes/Docker-OSX) project (GPL-3.0).

This folder used to hold a copy of that project. It now just points to upstream,
so you always get the current, maintained version.

## Requirements

- Linux host with KVM enabled (`ls /dev/kvm`)
- Docker
- An X11 display for the VM window (or use upstream's VNC/headless images)

## Quick start

```bash
docker run -it \
  --device /dev/kvm \
  -p 50922:10022 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e "DISPLAY=${DISPLAY:-:0.0}" \
  sickcodes/docker-osx:latest
```

Port `50922` forwards to SSH inside the VM. For other macOS versions,
headless/VNC images and Helm charts, see the
[upstream README](https://github.com/sickcodes/Docker-OSX#readme).

> Running macOS on non-Apple hardware may conflict with Apple's license terms.
> Check before using it beyond testing.
