# Changelog

All notable changes to the AAOF project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
AAOF uses [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

---

## [0.2.0] — 2024-01-15

### Added — Phase 1 Foundation

**Core Framework**
- `agent.md` — Complete 7-step operational workflow for the Agnostic Orchestrator Agent
- STEP 5: Validation & Test (build → run → health check → PASS/FAIL)
- STEP 6: Rollback Gate (notify → retry/rollback/abort → wait for user)
- STEP 7: Consolidation (renumbered from old STEP 5)
- New session state variables: `VAR_AVAILABLE_MCP`, `VAR_VALIDATION_RESULT`, `VAR_RETRY_COUNT`

**Rules Library**
- `rules/development_rules.md` — Code quality, file size limits (differentiated by type), naming conventions, modularity
- `rules/docker_rules.md` — Container-first mandate, dev container pattern, multi-stage Dockerfiles, Compose best practices
- `rules/kubernetes_rules.md` — Minikube-first, 1 resource per YAML, Kustomize, health probes
- `rules/security_rules.md` — No hardcoded secrets, non-root users, minimal images, .gitignore/.dockerignore enforcement
- `rules/error_handling_rules.md` — Error categories, auto-fix vs ask policy, retry strategy (max 3), rollback procedure
- `rules/mcp_rules.md` — MCP inventory at bootstrap, tool preference order, missing MCP policy

**Templates**
- `templates/Dockerfile.dev` — Development container template
- `templates/Dockerfile.app` — Multi-stage production Dockerfile template
- `templates/docker-compose.yml` — Production Compose template with health checks and resource limits
- `templates/docker-compose.dev.yml` — Dev override with volume mounts and debug ports
- `templates/.env.example` — Environment variables template
- `templates/k8s/namespace.yaml` — Kubernetes namespace template
- `templates/k8s/deployment.yaml` — Deployment with probes and security context
- `templates/k8s/service.yaml` — Service template
- `templates/k8s/configmap.yaml` — ConfigMap template
- `templates/k8s/kustomization.yaml` — Kustomize base configuration

**Project Structure**
- `config.json` — Project configuration template
- `session/session_state.json.example` — Session state template with all variables
- `output/deployed_state.json.example` — Deployed state template
- `specs/active/`, `specs/history/`, `session/`, `output/`, `backups/` directories
- `GEMINI.md` — Gemini CLI auto-loaded instructions
- `CONTRIBUTING.md` — Contributing guidelines
- `.gitignore` — Appropriate ignores for AAOF projects
- `docs/guides/gemini-cli-setup.md` — Step-by-step Gemini CLI integration guide

**Documentation**
- `README.md` — Complete rewrite with project structure, workflow, platforms, prerequisites, quick start, and roadmap

### Changed

- Renamed `Agent.md` → `agent.md` (lowercase convention)
- Updated line limit rule: differentiated by file type (200 for source, 300 for docs, logical separation for infra)
- `VAR_SESSION_STEP` range extended from 0-5 to 0-7

---

## [0.1.0] — 2024-01-01

### Added — Initial Commit

- `Agent.md` — Initial operational manual with 5-step workflow
- `README.md` — Initial project description
