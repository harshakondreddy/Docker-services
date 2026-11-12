# Docker Services

Small, self-contained container setups I use for labs, testing and day-to-day
platform work. Each folder runs on its own and has its own README.

| Folder | What it does | Runs on |
|---|---|---|
| [`local-llm/`](local-llm/) | Ollama serving the Gemma 3 4B model, with the model pulled by an init container | Kubernetes |
| [`init-container/`](init-container/) | Init container that waits until dependent services (HTTP/HTTPS) return `200` before the main app starts | Kubernetes |
| [`windows-vm/`](windows-vm/) | Windows 11/10/Server in Docker with RDP, built on [dockur/windows](https://github.com/dockur/windows) | Docker Compose |
| [`macos-vm/`](macos-vm/) | macOS in Docker, using [sickcodes/Docker-OSX](https://github.com/sickcodes/Docker-OSX) | Docker |

## Quick start

```bash
git clone https://github.com/harshakondreddy/Docker-services
cd Docker-services

# Local LLM on Kubernetes (pick your namespace)
kubectl apply -n <namespace> -f local-llm/ollama-gemma3-4b.yaml

# Init container image
docker build -t dependency-check init-container/

# Windows VM
cd windows-vm && docker compose up -d
```

## Init container usage

Add it to a Pod's `initContainers` and set:

| Variable | Example | Purpose |
|---|---|---|
| `URLs` | `api:8080;db-proxy:9000` | `;`-separated endpoints to check |
| `RETRY_TIME` | `10` | Seconds between retries |
| `ELASTIC_HOST` | `elasticsearch:9200` | Optional endpoint checked over HTTPS with basic auth |
| `ELASTIC_USERNAME` / `ELASTIC_PASSWORD` | from a Secret | Credentials for `ELASTIC_HOST` |

The container exits `0` once every endpoint returns `200`, so the main container starts only when its dependencies are up.

## Values to replace

Everything environment-specific has been turned into a placeholder or a variable.
Set these before you deploy.

| Placeholder / variable | File | Replace with | Default if not set |
|---|---|---|---|
| `<namespace>` (the `-n` flag) | `local-llm/ollama-gemma3-4b.yaml` | Namespace the Ollama resources go into | none, `-n` is required |
| `storageClassName` (commented out) | `local-llm/ollama-gemma3-4b.yaml` | Your cluster's StorageClass, e.g. an NFS provisioner | cluster default StorageClass |
| `nodePort: 32080` | `local-llm/ollama-gemma3-4b.yaml` | A free port in your NodePort range (30000–32767) | `32080` |
| `<node-ip>` | `local-llm/README.md` | IP or DNS name of any cluster node | — |
| `URLs` | init container env | `;`-separated `host:port` list the app depends on, in `service.namespace:port` form | — (required) |
| `ELASTIC_HOST` | `init-container/healthcheck.sh` | Elasticsearch `service.namespace:port`, exactly as written in `URLs` | `elasticsearch:9200` |
| `ELASTIC_USERNAME` / `ELASTIC_PASSWORD` | init container env | Elasticsearch user and password, from a Kubernetes Secret | unset, so no auth is used |
| `RETRY_TIME` | init container env | Seconds between checks | — (required) |
| `RDP_USER` / `RDP_PASS` | `windows-vm/.env` | Windows login to create on first boot | — (required) |
| `BIND_ADDR`, `RDP_PORT`, `VNC_PORT` | `windows-vm/.env` | Host IP and ports to publish on | `127.0.0.1`, `3389`, `8006` |

> `ELASTIC_HOST` must match the entry in `URLs` character for character, otherwise
> that endpoint is checked over plain HTTP without auth.

Example init container block:

```yaml
initContainers:
  - name: wait-for-deps
    image: dependency-check:latest
    env:
      - name: URLs
        value: "<es-service>.<namespace>:9200;<api-service>.<namespace>:8080"
      - name: ELASTIC_HOST
        value: "<es-service>.<namespace>:9200"
      - name: RETRY_TIME
        value: "10"
      - name: ELASTIC_USERNAME
        valueFrom: { secretKeyRef: { name: <es-secret>, key: username } }
      - name: ELASTIC_PASSWORD
        valueFrom: { secretKeyRef: { name: <es-secret>, key: password } }
```

## Notes

- No credentials are stored in this repo. Pass them at runtime through `.env` files or Kubernetes Secrets.
- The VM setups need a Linux host with KVM (`ls /dev/kvm`).
- Third-party projects keep their own licenses. See the links above.

## License

[MIT](LICENSE) for the files in this repo.
