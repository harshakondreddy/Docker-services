# Windows in Docker — RDP Access

Run **Windows 11** (or older editions) inside Docker with full RDP support,
powered by [dockur/windows](https://github.com/dockur/windows) (QEMU/KVM).

---

## Host Requirements

| Requirement | Check |
|---|---|
| Linux host with KVM | `ls /dev/kvm` |
| Docker ≥ 20.10 | `docker --version` |
| Docker Compose v2 | `docker compose version` |
| ≥ 4 GB free RAM | `free -h` |
| ≥ 64 GB free disk | `df -h` |

---

## Quick Start (Docker Compose — recommended)

```bash
# 1. Clone / enter the repo
git clone https://github.com/harshakondreddy/Docker-services && cd Docker-services/windows-vm

# 2. Create your credentials file
cp .env.example .env
nano .env          # set RDP_USER and a strong RDP_PASS

# 3. Start the container (first boot downloads & installs Windows ~5-10 min)
docker compose up -d

# 4. Watch progress in the VNC web UI
open http://localhost:8006   # or browse from any machine via SSH tunnel

# 5. Once Windows is installed, RDP in
#    (use Microsoft Remote Desktop, Remmina, mstsc, etc.)
#    Host: localhost   Port: 3389
#    User / Pass: whatever you set in .env
```

---

## Safe `docker run` Command (single-container)

Use this if you prefer plain Docker without Compose.
Replace the `<...>` placeholders before running.

```bash
docker run -d \
  --name windows-rdp \
  --privileged \
  --device /dev/kvm \
  --device /dev/net/tun \
  -v windows-data:/storage \
  -p 127.0.0.1:3389:3389/tcp \
  -p 127.0.0.1:3389:3389/udp \
  -p 127.0.0.1:8006:8006/tcp \
  -e VERSION="11" \
  -e RAM_SIZE="4G" \
  -e CPU_CORES="2" \
  -e DISK_SIZE="64G" \
  -e USERNAME="<your-rdp-username>" \
  -e PASSWORD="<your-strong-password>" \
  --memory="6g" \
  --cpus="4" \
  --restart unless-stopped \
  dockur/windows:latest
```

> **Tip:** Ports are bound to `127.0.0.1` (loopback only).
> To reach RDP from a remote machine, create an SSH tunnel first:
> ```bash
> ssh -L 3389:localhost:3389 user@your-server-ip
> # Then RDP to localhost:3389 on your local machine
> ```

---

## Security Hardening

| Practice | Why |
|---|---|
| Bind ports to `127.0.0.1` | RDP never exposed directly to the internet |
| SSH tunnel for remote access | Encrypted transport, no open RDP port in firewall |
| Strong password (≥16 chars, mixed) | Brute-force protection |
| Docker resource limits (`--memory`, `--cpus`) | Prevent container from starving the host |
| `.env` in `.gitignore` | Credentials never committed to version control |
| Named volume for disk image | Data persists; easy to back up |

---

## Windows Edition Options

Set `VERSION` (env var) to:

| Value | Edition |
|---|---|
| `11` | Windows 11 Pro (default) |
| `10` | Windows 10 Pro |
| `2022` | Windows Server 2022 |
| `2019` | Windows Server 2019 |

---

## Useful Commands

```bash
# View real-time logs
docker compose logs -f

# Stop without deleting data
docker compose stop

# Destroy container (keeps disk volume)
docker compose down

# Destroy everything including the Windows disk image
docker compose down -v

# Open VNC web console (alternative to RDP, for troubleshooting)
open http://localhost:8006
```

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Operation not permitted` on start | Host KVM not enabled or `/dev/kvm` missing |
| Black screen in VNC for >15 min | First-boot Windows install still running — wait |
| RDP connection refused | Windows not fully booted yet; check VNC first |
| Slow performance | Increase `RAM_SIZE` / `CPU_CORES` in `.env` |
