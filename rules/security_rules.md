# Security Rules

> **Purpose:** Security policies for all code, containers, and infrastructure generated
> by the Agnostic Orchestrator Agent. These rules are mandatory and non-negotiable.
>
> **Scope:** All AAOF projects, all deployment targets.

---

## 1. No Hardcoded Secrets

**Never hardcode secrets, passwords, API keys, or tokens in any file.**

This includes source code, Dockerfiles, docker-compose.yml, and Kubernetes manifests.

✅ Correct approaches:
- **Docker:** Use `.env` files (not committed to git) or Docker Secrets.
- **Kubernetes:** Use Kubernetes Secrets (sourced from a secret manager in production).
- **Source code:** Read from environment variables (`os.environ`, `process.env`, etc.).
- **Config files:** Use `${VARIABLE_NAME}` interpolation.

❌ Never:
```yaml
# docker-compose.yml
environment:
  - DB_PASSWORD=my_secret_password   # NEVER DO THIS
```

✅ Always:
```yaml
# docker-compose.yml
env_file:
  - .env   # .env is in .gitignore
```

---

## 2. Non-Root Container Users

**All containers must run as a non-root user.**

```dockerfile
# Create a non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Switch to non-root user before CMD/ENTRYPOINT
USER appuser
```

For Alpine-based images:
```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

---

## 3. Minimal Base Images

Use the smallest image that provides the necessary runtime:

| Use Case | Preferred Base Image |
| :--- | :--- |
| Node.js runtime | `node:20-alpine` |
| Python runtime | `python:3.12-slim` |
| Java runtime | `eclipse-temurin:21-jre-alpine` |
| Go binary | `gcr.io/distroless/static-debian12` |
| Generic Linux | `alpine:3.20` |
| Build stage | Use full SDK image (e.g., `node:20`, `maven:3.9`) |

Never use `latest` in production. Always pin to a specific version tag.

---

## 4. .gitignore Enforcement

The following must always be in `.gitignore`:

```
# Secrets and environment
.env
.env.*
!.env.example

# Session state (contains paths and run-time data)
session/session_state.json

# Backups (large, not needed in git)
backups/

# Output (generated, not source)
output/
!output/*.example
```

---

## 5. .dockerignore Enforcement

Every project must include `.dockerignore` to prevent leaking sensitive files into
Docker build contexts:

```
.git
.gitignore
.env
.env.*
!.env.example
session/
backups/
*.md
```

---

## 6. No Sensitive Data in Git

Before committing, verify:

- No `.env` files (only `.env.example` with placeholder values)
- No private keys, certificates, or tokens
- No `session_state.json` (contains runtime paths and state)
- No generated `output/` files with embedded secrets

If a secret is accidentally committed:
1. Rotate the secret immediately.
2. Remove it from git history using `git filter-repo` or BFG Repo Cleaner.
3. Force-push and notify collaborators.

---

## 7. Image Scanning Recommendations

Before using an image in production:

- Run `docker scout cves <image>` (Docker Scout) or `trivy image <image>` (Trivy).
- Address CRITICAL and HIGH severity CVEs.
- Pin base images to digest hashes in production for immutability:
  ```dockerfile
  FROM node:20-alpine@sha256:<digest>
  ```

---

## 8. Network Policies

- Internal services must not be accessible from outside the compose/cluster network.
- Only the entry point (API gateway, reverse proxy) should be exposed externally.
- In Kubernetes, apply NetworkPolicy resources to restrict pod-to-pod communication.
- Database ports (5432, 3306, 27017) must never be exposed on the host in production.

---

## 9. Read-Only Filesystems

Where possible, mount the application filesystem as read-only:

```yaml
# docker-compose.yml
services:
  api:
    read_only: true
    tmpfs:
      - /tmp         # Allow writes only to /tmp
```

```yaml
# Kubernetes Deployment
securityContext:
  readOnlyRootFilesystem: true
```

---

## 10. Capability Dropping

In Kubernetes, drop all Linux capabilities and only add what is strictly needed:

```yaml
securityContext:
  capabilities:
    drop:
      - ALL
  allowPrivilegeEscalation: false
  runAsNonRoot: true
```
