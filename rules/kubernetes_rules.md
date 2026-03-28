# Kubernetes Rules

> **Purpose:** Kubernetes deployment patterns, manifest conventions, and Minikube-first
> testing strategy for all AAOF projects targeting Kubernetes.
>
> **Scope:** All projects with `K8S` in `VAR_DEPLOY_TARGET`.

---

## 1. Minikube-First Approach

**All Kubernetes testing must be done on Minikube** before targeting any cloud provider.
This ensures:

- No cloud costs during development and validation
- Consistent environment for all contributors
- Easy reset (`minikube delete && minikube start`)

### Minikube Setup Assumptions

```bash
minikube start --driver=docker --memory=4096 --cpus=2
minikube addons enable ingress
eval $(minikube docker-env)   # Use Minikube's Docker daemon for local images
```

---

## 2. One Resource Per YAML File

**Never put multiple Kubernetes resources in the same YAML file.**

✅ Correct:
```
k8s/
├── namespace.yaml
├── deployment.yaml
├── service.yaml
├── configmap.yaml
└── secret.yaml
```

❌ Wrong:
```yaml
# A single file with multiple resources separated by ---
apiVersion: v1
kind: Namespace
---
apiVersion: apps/v1
kind: Deployment
```

This makes diffs, review, and targeted `kubectl apply` much cleaner.

---

## 3. Kustomize for Templating

Use **Kustomize** (built into `kubectl`) for environment-specific overlays:

```
k8s/
├── base/
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    └── prod/
        └── kustomization.yaml
```

Apply with: `kubectl apply -k k8s/overlays/dev`

---

## 4. Namespace Isolation

- Every project must have its own namespace.
- Never deploy to the `default` namespace in a shared cluster.
- Namespace name convention: `<project-name>-<env>` e.g. `my-app-dev`, `my-app-prod`.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-app-dev
  labels:
    app.kubernetes.io/managed-by: aaof
```

---

## 5. Standard Resource Patterns

### Deployment

- Always set `replicas` explicitly (even if 1).
- Always define `resources.requests` and `resources.limits`.
- Always define `livenessProbe` and `readinessProbe`.
- Use `RollingUpdate` strategy with `maxUnavailable: 0` for zero-downtime.
- Use `app.kubernetes.io/*` labels.

### Service

- Use `ClusterIP` for internal services.
- Use `NodePort` only for Minikube development access.
- Use `LoadBalancer` or `Ingress` for external production access.

### ConfigMap

- Store non-sensitive configuration as ConfigMaps.
- Mount as files (not env vars) for complex configs.
- Name convention: `<app-name>-config`.

### Secret

- Never store secrets in git. See `security_rules.md`.
- Use Kubernetes Secrets for credentials passed into pods.
- For production, use an external secret manager (Vault, AWS Secrets Manager).
- Name convention: `<app-name>-secret`.

---

## 6. Health Probes

Every Deployment must define both probes:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 20

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
```

---

## 7. Resource Requests and Limits

Always set both:

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "256Mi"
    cpu: "500m"
```

Omitting limits can cause a single pod to consume all cluster resources.

---

## 8. PersistentVolumeClaim for Stateful Workloads

- Databases and stateful services must use PVCs — never `hostPath` volumes.
- Use `StorageClass: standard` for Minikube.
- Name convention: `<service-name>-pvc`.

---

## 9. Docker Compose to K8s Translation

When the user requests both Docker and K8s targets, the agent should:

1. Implement with Docker Compose first (STEP 4).
2. Validate with Docker (STEP 5).
3. Translate to K8s manifests following these rules:
   - Each `docker-compose` service → Deployment + Service YAML
   - Compose `volumes` → PVC
   - Compose `environment` → ConfigMap or Secret
   - Compose `ports` → Service `targetPort`/`port`
4. Apply and validate on Minikube (second STEP 5 pass).
