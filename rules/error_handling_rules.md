# Error Handling Rules

> **Purpose:** Defines how the Agnostic Orchestrator Agent should handle failures,
> interpret error logs, apply retry strategies, and execute rollback procedures.
>
> **Scope:** All AAOF projects. Referenced primarily in STEP 5 (Validation) and
> STEP 6 (Rollback Gate) of the agent workflow.

---

## 1. Error Categories

Classify every error into one of these categories before deciding how to respond:

| Category | Description | Examples |
| :--- | :--- | :--- |
| **BUILD_ERROR** | Compilation or image build failure | Syntax error, missing dependency, COPY fails |
| **RUNTIME_ERROR** | Container starts but crashes | Application exception, OOM killed, segfault |
| **CONFIG_ERROR** | Misconfiguration detected | Missing env var, wrong port, bad volume path |
| **NETWORK_ERROR** | Connectivity failure between services | DB unreachable, port conflict, DNS failure |
| **DEPENDENCY_ERROR** | External service unavailable | Registry unreachable, package download fails |

---

## 2. How to Interpret Docker/K8s Error Logs

### Docker Compose

```bash
docker-compose logs <service>          # Full logs for a service
docker-compose logs --tail=50 <service>  # Last 50 lines
docker inspect <container_id>          # Full container metadata (exit code, state)
```

Key signals to look for:
- Exit code `1` → Application error (check app logs)
- Exit code `137` → OOM killed (increase memory limit)
- Exit code `126/127` → Command not found (check Dockerfile CMD/ENTRYPOINT)
- `Exited (1)` in `docker ps -a` → Runtime crash

### Kubernetes

```bash
kubectl describe pod <pod-name> -n <namespace>   # Events and state
kubectl logs <pod-name> -n <namespace>           # Application logs
kubectl logs <pod-name> -n <namespace> --previous  # Logs from crashed container
```

Key signals:
- `CrashLoopBackOff` → Runtime error (inspect logs with `--previous`)
- `ImagePullBackOff` → Image not found or registry unreachable
- `OOMKilled` → Memory limit too low
- `Pending` → Insufficient cluster resources or PVC not bound

---

## 3. When to Auto-Fix vs Ask the User

| Situation | Action |
| :--- | :--- |
| Missing environment variable with a safe default | Auto-fix: add default to `.env.example`, ask user to confirm |
| Port conflict (port already in use) | Auto-fix: suggest alternative port, update compose/manifest |
| Build dependency missing (package not found) | Auto-fix: add to Dockerfile, retry |
| OOM killed (need more memory) | Auto-fix: increase resource limit, retry |
| Application logic error (stack trace) | **Ask user** — this requires domain knowledge |
| Database schema mismatch | **Ask user** — risk of data loss |
| Network policy blocking traffic | Auto-fix if config is clearly wrong; ask if ambiguous |

**Rule:** Auto-fix only when the solution is unambiguous and carries no risk of data
loss or behavioral change. When in doubt, ask.

---

## 4. Retry Strategy

The agent may retry STEP 4 + STEP 5 automatically up to **3 times** total.

- `VAR_RETRY_COUNT` in `session_state.json` tracks the current count.
- On each retry, the agent must:
  1. Log the error and the attempted fix in `changelog.md`.
  2. Increment `VAR_RETRY_COUNT`.
  3. Execute the fix (update code, Dockerfile, config).
  4. Re-run STEP 4 and STEP 5.
- If `VAR_RETRY_COUNT` reaches 3 and the validation still fails, go to STEP 6
  (Rollback Gate) and present only **Rollback** or **Abort** options (no more Retry).

---

## 5. Logging Requirements for Debugging

All generated services must:

- Log to **stdout/stderr** (not to files) — Docker/K8s collects these automatically.
- Use **structured logging** (JSON format) in production.
- Include these fields in every log entry:
  - `timestamp` (ISO 8601)
  - `level` (DEBUG, INFO, WARN, ERROR)
  - `service` (service name)
  - `message`
  - `error` (if applicable, include stack trace)

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "ERROR",
  "service": "api",
  "message": "Database connection failed",
  "error": "connect ECONNREFUSED 127.0.0.1:5432"
}
```

---

## 6. Rollback Procedures

When the user selects **Rollback** in STEP 6:

1. **Identify backup:** Find the most recent backup in
   `backups/YYYYMMDD_HHMM_[TASK_NAME]/`.
2. **Stop running services:** `docker-compose down` or `kubectl delete -k k8s/`.
3. **Restore files:** Copy backup contents back to `output/`.
4. **Restore session state:** Copy the backed-up `session_state.json` back to `session/`.
5. **Verify:** Confirm the restored files match the backup (check key files).
6. **Report:** Log the rollback in `changelog.md` with timestamp and reason.
7. **Restart services** (optional, based on user confirmation):
   `docker-compose up -d` with the restored configuration.
8. **Set `VAR_VALIDATION_RESULT`** to the result of the restored state.

---

## 7. Abort Procedure

When the user selects **Abort** in STEP 6:

1. Do NOT modify any files.
2. Save the current `session_state.json` with a note explaining why the session
   was aborted and what the last known error was.
3. Log the abort in `changelog.md`.
4. Inform the user of the exact state: which files were modified, which were not.
5. The session can be resumed later by loading `session_state.json`.
