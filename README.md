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

## Notes

- No credentials are stored in this repo. Pass them at runtime through `.env` files or Kubernetes Secrets.
- The VM setups need a Linux host with KVM (`ls /dev/kvm`).
- Third-party projects keep their own licenses. See the links above.

## License

[MIT](LICENSE) for the files in this repo.
