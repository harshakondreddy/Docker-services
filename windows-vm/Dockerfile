# Windows in Docker with RDP access
# Built on dockurr/windows (github.com/dockur/windows) which runs Windows via QEMU/KVM inside Docker
# Supports: Windows 11, Windows 10, Windows Server 2022, etc.
#
# Requirements (host):
#   - Linux host with KVM enabled  (check: ls /dev/kvm)
#   - Docker with --privileged or specific device access
#   - At least 4 GB RAM and 64 GB disk allocated

ARG WINDOWS_VERSION=11

FROM dockurr/windows:latest

# ARG declared before FROM is not visible after it, so declare it again
ARG WINDOWS_VERSION

# ── Environment: Windows edition ────────────────────────────────────────────
# VERSION options:
#   "11"      → Windows 11 Pro (latest, default)
#   "10"      → Windows 10 Pro
#   "2022"    → Windows Server 2022
#   "2019"    → Windows Server 2019
ENV VERSION=${WINDOWS_VERSION}

# ── Resources ────────────────────────────────────────────────────────────────
# These can be overridden at runtime via docker run -e or docker-compose
ENV RAM_SIZE=4G
ENV CPU_CORES=2
ENV DISK_SIZE=64G

# ── RDP / display ────────────────────────────────────────────────────────────
# RDP is enabled automatically by dockur/windows.
# The VNC web UI (port 8006) is also exposed for initial setup.
EXPOSE 8006/tcp
EXPOSE 3389/tcp
EXPOSE 3389/udp
