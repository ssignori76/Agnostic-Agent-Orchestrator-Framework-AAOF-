# 🔐 rules/security_profiles.md — Environment Security Profiles

> **MANDATORY:** Every project session MUST have an active security profile.
> The agent CANNOT proceed past STEP 1 without a confirmed `VAR_SECURITY_PROFILE`.

---

## 1. Overview

Security requirements vary significantly between lab, staging, and production environments.
This file defines three profiles — `lab`, `staging`, and `production` — and the enforcement
level for each security rule in each profile.

**Profile definitions:**

| Profile | Description |
|---------|-------------|
| `lab` | Internal development/lab environment. No external access. Speed and convenience prioritised over strict hardening. |
| `staging` | Pre-production environment. External or team access may exist. Near-production hardening required. |
| `production` | Live environment. Strict hardening required. All rules enforced with zero tolerance. |

---

## 2. Security Enforcement Table

| Rule | Lab/Dev | Staging | Production |
|------|---------|---------|------------|
| TLS/HTTPS | ⬜ Optional (document choice in plan) | ✅ Required (self-signed OK) | ✅ Required (CA-signed) |
| Secrets in `docker-compose.yml` | ⚠️ WARN (log in compliance report) | ❌ FAIL | ❌ FAIL |
| DB port exposed on host | ✅ Allowed for debugging | ❌ FAIL | ❌ FAIL |
| Password hashing (application level) | ⚠️ WARN | ✅ Required | ✅ Required |
| Non-root containers | ✅ Required always | ✅ Required | ✅ Required |
| `.env.example` present | ✅ Required always | ✅ Required | ✅ Required |
| `.dockerignore` present | ✅ Required always | ✅ Required | ✅ Required |
| Network isolation (Compose) | ⚠️ WARN | ✅ Required | ✅ Required |
| Resource limits (Compose) | ⬜ Optional | ✅ Required | ✅ Required |
| Image scanning | ⬜ Recommended | ✅ Required | ✅ Required + block on CRITICAL |
| Cookie security (HttpOnly, SameSite) | ⚠️ WARN | ✅ Required | ✅ Required |
| Input validation | ⚠️ WARN | ✅ Required | ✅ Required |
| File headers (`development_rules` §2) | ⬜ Optional | ✅ Required | ✅ Required |
| Read-only filesystem | ⬜ Optional | ⚠️ WARN | ✅ Required |
| XSS prevention (no raw `innerHTML` with untrusted data) | ⚠️ WARN | ✅ Required | ✅ Required |

**Legend:**
- ✅ Required — violation is a `FAIL` (blocking)
- ⚠️ WARN — violation is logged as a warning; execution may continue with user acknowledgment
- ⬜ Optional — rule is recommended but not enforced
- ❌ FAIL — violation is always blocking regardless of context

---

## 3. Profile Selection

### 3.1 Automatic Selection

The agent reads `environment_context.type` from `config.json`:

```json
"environment_context": {
  "type": "lab",
  "tls_required": false,
  "external_access": false,
  "secrets_strictness": "relaxed"
}
```

Valid values for `type`: `lab`, `staging`, `production`.

### 3.2 Missing Profile — Agent MUST Ask

If `environment_context.type` is not set in `config.json`, the agent **MUST** ask the user:

> "⚠️ No environment type is set in `config.json`. Before I can proceed, I need to know:
> **Is this a `lab/dev`, `staging`, or `production` environment?**
> This determines which security rules are enforced. I cannot proceed without this classification."

The agent **CANNOT** proceed past STEP 1 without a confirmed profile.

### 3.3 Storing the Active Profile

Store the confirmed profile in `session_state.json` as `VAR_SECURITY_PROFILE`.

---

## 4. TLS Policy

| Environment | TLS Policy |
|-------------|-----------|
| `lab` | TLS is **optional**. If `tls_required` is `false` in `config.json`, the agent MAY omit HTTPS but MUST document the choice explicitly in the execution plan. |
| `staging` | TLS is **required**. Self-signed certificates are acceptable. The agent MUST configure HTTPS. |
| `production` | TLS is **required**. Only CA-signed certificates are acceptable. Self-signed certs are a FAIL. |

---

## 5. Secrets Policy

| Environment | Secrets Policy |
|-------------|---------------|
| `lab` | Hardcoded secrets in `docker-compose.yml` trigger a **WARN** that is logged in `output/compliance_report.md`. Execution may continue. |
| `staging` | Hardcoded secrets are a **FAIL**. All secrets MUST use `env_file: .env` or Docker Secrets. |
| `production` | Hardcoded secrets are a **FAIL**. All secrets MUST use Docker Secrets or a vault solution (HashiCorp Vault, AWS Secrets Manager, etc.). |

> **Applies always (all profiles):** `.env` files containing actual secret values MUST
> be listed in `.gitignore`. `.env.example` with placeholder values MUST always be present.

---

## 6. Non-Root Containers (Always Required)

Non-root container execution is **REQUIRED** for ALL profiles — `lab`, `staging`, and `production`.
There is no exemption for lab environments.

Every `Dockerfile` in `output/` MUST include a `USER` directive with a non-root user
before any `CMD` or `ENTRYPOINT` instruction.

---

## 7. Profile Confirmation at STEP 1

After loading the profile, the agent MUST present a confirmation to the user:

> "This project is classified as **[TYPE]**. Security profile loaded:
>
> - **TLS/HTTPS:** [implication]
> - **Secrets management:** [implication]
> - **Password hashing:** [implication]
> - **Network isolation:** [implication]
>
> Do you confirm this security profile?"

The user MUST explicitly confirm before `VAR_SECURITY_PROFILE` is written to `session_state.json`.
