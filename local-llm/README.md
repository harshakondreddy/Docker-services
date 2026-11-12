# Local LLM on Kubernetes (Ollama + Gemma 3 4B)

Runs [Ollama](https://ollama.com) with the `gemma3:4b` model inside a Kubernetes cluster.
CPU only, no GPU needed.

## What gets created

| Resource | Name | Notes |
|---|---|---|
| PersistentVolumeClaim | `ollama-gemma3-4b-data` | 10 Gi, keeps the model between restarts |
| Deployment | `ollama-gemma3-4b` | 1 replica, `Recreate` strategy (the volume is ReadWriteOnce) |
| Service | `ollama-gemma3-4b` | NodePort `32080` → container port `18080` |

An init container starts Ollama briefly, pulls `gemma3:4b` into the volume, then exits.
The main container starts only after the model is already on disk.

## Requirements

- A Kubernetes cluster with a default StorageClass (or set `storageClassName` in the PVC)
- A node with about **8 Gi of free memory and 4 CPU** (requests: 2 CPU / 6 Gi)
- Internet access from the cluster for the first model pull (about 3.3 GB)

## Deploy

```bash
kubectl create namespace llm            # or use an existing one
kubectl apply -n llm -f ollama-gemma3-4b.yaml
kubectl -n llm rollout status deploy/ollama-gemma3-4b --timeout=15m
```

The first start is slow because of the model download. Watch it with:

```bash
kubectl -n llm logs deploy/ollama-gemma3-4b -c pull-model -f
```

## Test

```bash
# from outside the cluster
curl http://<node-ip>:32080/api/generate \
  -d '{"model":"gemma3:4b","prompt":"Explain a Kubernetes init container in one line","stream":false}'

# or from your machine without the NodePort
kubectl -n llm port-forward svc/ollama-gemma3-4b 18080:18080
curl http://localhost:18080/api/tags
```

## Settings

| Env var | Value | Why |
|---|---|---|
| `OLLAMA_HOST` | `0.0.0.0:18080` | Listen on all interfaces, custom port |
| `OLLAMA_NUM_PARALLEL` | `1` | One request at a time, keeps memory predictable |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Only one model in memory |

The container runs with `allowPrivilegeEscalation: false`, all capabilities dropped,
and the `RuntimeDefault` seccomp profile.

## Security note

NodePort exposes the API on every node with **no authentication**. Keep it on a
trusted network, or change the Service to `ClusterIP` and use `port-forward` or an
Ingress with auth.

## Remove

```bash
kubectl delete -n llm -f ollama-gemma3-4b.yaml   # also deletes the PVC and the downloaded model
```
