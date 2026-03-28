# MCP Rules

> **Purpose:** Conventions for discovering, inventorying, and using Model Context
> Protocol (MCP) servers within the AAOF framework.
>
> **Scope:** All AAOF projects. Applies to any MCP-enabled AI agent (Claude Code,
> Gemini CLI, or others).

---

## 1. Core Principle: The Agent Knows Its Own MCPs

The agent already knows which MCP servers are configured — they are part of the AI
tool's configuration (e.g., Claude Code's `settings.json`, Gemini CLI's config).

**AAOF does not maintain a rigid list of required MCP servers.** The agent is
responsible for:

1. Discovering what MCPs it has available (STEP 0).
2. Using them intelligently when they provide the best tool for the job.
3. Explicitly telling the user when it needs an MCP it doesn't have.

---

## 2. Bootstrap: MCP Inventory (STEP 0)

At STEP 0, the agent must:

1. **Enumerate** all available MCP servers from its own configuration context.
2. **Record** them in `session_state.json` under `VAR_AVAILABLE_MCP`:
   ```json
   "VAR_AVAILABLE_MCP": ["filesystem", "docker", "git", "browser"]
   ```
3. **Log** the discovery in the session initialization notes.

If the agent cannot determine its available MCPs, it must set `VAR_AVAILABLE_MCP` to
`[]` and proceed using CLI tools only.

---

## 3. Tool Usage Preference Order

When multiple approaches are available for the same operation, prefer in this order:

1. **MCP server tool** — if an MCP provides a structured API for the operation
   (e.g., an MCP for Docker operations, filesystem writes, git commands).
2. **CLI command** — if no MCP is available, fall back to the equivalent shell command
   (`docker build`, `git commit`, `kubectl apply`).
3. **File write + manual step** — as a last resort, generate a script and instruct the
   user to run it manually.

---

## 4. Missing MCP Policy

If the agent determines it needs an MCP that is not in `VAR_AVAILABLE_MCP`:

1. **Do not silently fail** or attempt a workaround without telling the user.
2. **Explicitly state** which MCP is needed and why:
   > "I need the `docker` MCP server to manage containers directly. I don't see it in
   > my available MCPs. I can proceed using CLI commands instead — shall I continue
   > that way, or would you like to configure the Docker MCP server first?"
3. **Propose the CLI alternative** and wait for user confirmation.

---

## 5. No Framework Complexity for MCP

AAOF does not:
- Require specific MCP servers to function.
- Validate MCP configurations.
- Install or configure MCP servers on the user's behalf.

The agent adapts to whatever MCPs are available. The framework works with zero MCPs
(CLI-only mode) and also with a full suite of MCPs.

---

## 6. Common MCP Categories and CLI Fallbacks

| MCP Category | What It Enables | CLI Fallback |
| :--- | :--- | :--- |
| `filesystem` | Read/write files via structured API | `cat`, `echo`, `cp`, `mv` |
| `docker` | Container and image management | `docker`, `docker-compose` |
| `git` | Repository operations | `git` |
| `kubernetes` | Cluster operations | `kubectl`, `helm` |
| `browser` | Web access and scraping | `curl`, `wget` |
| `database` | Direct DB queries | DB CLI tools (psql, mysql) |

---

## 7. MCP Security Considerations

- MCPs run with the permissions of the agent process.
- Prefer using AAOF's sandboxed environment (see `docs/guides/gemini-cli-setup.md`)
  to limit what MCPs can access on the host.
- MCPs that access the filesystem should be scoped to the AAOF project directory.
- Never configure MCPs with production credentials during development.
