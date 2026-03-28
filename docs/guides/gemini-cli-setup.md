# Using AAOF with Google Gemini CLI

> **Audience:** Non-programmers and developers who want to use Google Gemini CLI as
> their AI agent within the AAOF framework.
>
> **Goal:** A step-by-step guide to set up Gemini CLI and launch your first AAOF
> session.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Install Gemini CLI](#2-install-gemini-cli)
3. [Clone the AAOF Repository](#3-clone-the-aaof-repository)
4. [Configure Your Project](#4-configure-your-project)
5. [How GEMINI.md Works](#5-how-geminimd-works)
6. [Security & Sandbox Recommendations](#6-security--sandbox-recommendations)
7. [First Run Walkthrough](#7-first-run-walkthrough)
8. [Tips and Troubleshooting](#8-tips-and-troubleshooting)

---

## 1. Prerequisites

Before starting, ensure you have the following installed and configured:

| Requirement | Version | How to Check |
| :--- | :--- | :--- |
| **Node.js** | 18 or higher | `node --version` |
| **npm** | 8 or higher | `npm --version` |
| **Docker** | 24 or higher | `docker --version` |
| **Docker Compose** | v2 | `docker compose version` |
| **Git** | any recent | `git --version` |
| **Google Account** | — | [accounts.google.com](https://accounts.google.com) |
| **Gemini API Key** | — | [Google AI Studio](https://aistudio.google.com/app/apikey) |

**Optional (for Kubernetes targets):**
- Minikube: [Install Minikube](https://minikube.sigs.k8s.io/docs/start/)
- kubectl: [Install kubectl](https://kubernetes.io/docs/tasks/tools/)

---

## 2. Install Gemini CLI

Gemini CLI is Google's official command-line AI agent tool.

```bash
npm install -g @google/gemini-cli
```

Verify the installation:

```bash
gemini --version
```

### Authenticate with Google

```bash
gemini auth login
```

This opens a browser window to authenticate with your Google account.
Follow the prompts to grant the necessary permissions.

Alternatively, set your API key directly:

```bash
export GEMINI_API_KEY="your-api-key-here"
```

> **Tip:** Add the `export` line to your `~/.bashrc` or `~/.zshrc` to make it
> persistent across terminal sessions.

---

## 3. Clone the AAOF Repository

```bash
git clone https://github.com/ssignori76/Agnostic-Agent-Orchestrator-Framework-AAOF-.git my-project
cd my-project
```

You now have the full AAOF framework structure in `my-project/`.

---

## 4. Configure Your Project

### 4.1 Edit config.json

Open `config.json` and describe your project:

```json
{
  "project_name": "my-webapp",
  "project_description": "A Node.js REST API with PostgreSQL database",
  "stack": {
    "languages": ["javascript"],
    "frameworks": ["express"],
    "databases": ["postgresql"]
  },
  "deploy_targets": ["DOCKER"]
}
```

### 4.2 Write your first spec

Create a file in `specs/active/` describing what you want to build.
The name should start with a number for ordering:

```bash
# Example: specs/active/001-user-management.md
```

Inside the file, write in plain language:

```markdown
# Feature: User Management

## What I need
- A REST API endpoint to register new users
- Each user has: email, password (hashed), name, created_at
- Endpoint: POST /api/users
- Returns: user ID and creation timestamp
- Database: PostgreSQL (already defined in config.json)
```

### 4.3 Set up your environment

Copy the environment template:

```bash
cp templates/.env.example .env
```

Edit `.env` and fill in your actual values. Never commit `.env` to git.

---

## 5. How GEMINI.md Works

The `GEMINI.md` file at the root of this project is **automatically read by Gemini CLI**
when you launch it from this directory. It acts as the agent's initial instructions.

The AAOF `GEMINI.md` tells Gemini to:

1. Read `agent.md` (the 7-step workflow).
2. Read all files in `rules/` (the operational policies).
3. Read `config.json` and any existing session state.
4. Respond with a ready confirmation before accepting any task.

**You do not need to manually copy any instructions** — the `GEMINI.md` file handles it
automatically every time you start a new Gemini CLI session in this directory.

### Global vs Project-Level GEMINI.md

Gemini CLI supports a hierarchical GEMINI.md system:

- **Global:** `~/.gemini/GEMINI.md` — Applied to ALL Gemini sessions on your machine.
- **Project-level:** `./GEMINI.md` (this file) — Applied only when Gemini is launched
  from this directory.

The project-level file takes precedence. AAOF uses only the project-level file to keep
the configuration self-contained.

---

## 6. Security & Sandbox Recommendations

Since Gemini CLI can read and write files and execute commands, it's important to
understand the security implications and configure it appropriately.

### 6.1 Work Inside the Project Directory

Always launch Gemini CLI from inside your AAOF project directory:

```bash
cd /path/to/my-project
gemini
```

Gemini CLI's file access is naturally scoped to the directory you launch it from and
its subdirectories. This limits the blast radius of any unexpected behavior.

### 6.2 Use the --sandbox Flag

The `--sandbox` flag restricts Gemini CLI's ability to make system-level changes:

```bash
gemini --sandbox
```

This enables an additional isolation layer. Recommended for all AAOF sessions.

### 6.3 Tool Call Approval Settings

Gemini CLI can be configured to ask for approval before executing commands:

```bash
gemini --tool-call-approval prompt
```

Options:
- `prompt` — Ask for approval before every tool call (most secure, slower).
- `auto` — Execute all tool calls automatically (fastest, less control).
- `never` — Disable tool calls entirely (read-only mode).

**Recommendation for beginners:** Start with `prompt` to understand what the agent
is doing. Once you trust the workflow, switch to `auto` for faster iteration.

### 6.4 Dedicated OS User (Optional)

For extra isolation, create a dedicated OS user for Gemini CLI sessions:

```bash
# Create a dedicated user (Linux/macOS)
sudo useradd -m aaof-agent
sudo chown -R aaof-agent:aaof-agent /path/to/my-project

# Run Gemini CLI as the dedicated user
sudo -u aaof-agent gemini --sandbox
```

This ensures that even if something goes wrong, the agent can only access files owned
by the `aaof-agent` user.

### 6.5 Docker as the Ultimate Sandbox

For maximum isolation, run Gemini CLI **inside a Docker container**. This gives you
full OS-level isolation:

```bash
# Run an interactive container with the project directory mounted
docker run -it --rm \
  -v "$(pwd):/workspace" \
  -w /workspace \
  -e GEMINI_API_KEY="${GEMINI_API_KEY}" \
  node:20-alpine \
  sh -c "npm install -g @google/gemini-cli && gemini --sandbox"
```

With this approach:
- The agent is fully isolated from your host system.
- It can only access files in the mounted `/workspace` directory.
- It can still use Docker (via Docker-in-Docker or Docker socket mounting if needed).

> **Note on Docker-in-Docker:** If your agent needs to run `docker build` and
> `docker-compose`, you will need to mount the Docker socket:
> `-v /var/run/docker.sock:/var/run/docker.sock`
> Be aware that this grants significant privileges — only do this on a trusted machine.

---

## 7. First Run Walkthrough

### Step 1: Launch Gemini CLI

```bash
cd /path/to/my-project
gemini --sandbox
```

### Step 2: Agent Bootstrap

Gemini will automatically read `GEMINI.md`, which instructs it to read `agent.md`,
all `rules/` files, and `config.json`.

Expected response from the agent:
```
✅ AAOF Agent ready. I have read agent.md and all rules/.
Project: my-webapp. Current session step: 0.
How can I help?
```

### Step 3: Describe Your Task

Type a natural language description of what you want to build:

```
I have a spec in specs/active/001-user-management.md.
Please start the workflow to implement it.
```

### Step 4: Review the Execution Plan (STEP 2)

The agent will present its execution plan. Review it carefully:

```
📋 EXECUTION PLAN
─────────────────
1. Create Dockerfile.dev for Node.js 20 development environment
2. Create src/routes/users.js — POST /api/users endpoint
3. Create src/services/userService.js — business logic
4. Create src/models/user.js — database model
5. Update docker-compose.yml with api and db services
6. Run STEP 5 validation: docker-compose build, up -d, health check

Shall I proceed? (Type GO to start)
```

Type `GO` to authorize the agent to proceed.

### Step 5: Monitor Progress

The agent will work through the steps, writing files and showing its progress.
You will be notified at STEP 5 whether the build and validation passed.

### Step 6: Review the Output

All generated files are in the `output/` directory. Check them before deploying.

---

## 8. Tips and Troubleshooting

### Agent doesn't read agent.md automatically

Ensure you are launching Gemini CLI from the project root directory (where `GEMINI.md`
is located):

```bash
ls GEMINI.md   # Should exist
gemini
```

### Authentication errors

```bash
gemini auth login    # Re-authenticate
gemini auth status   # Check current auth status
```

### Agent gets stuck or loses context

The session state is always saved in `session/session_state.json`. If the agent loses
context, you can resume:

```
Resume from session/session_state.json. Load the state and continue from
where we left off.
```

### Docker build fails

The agent will automatically enter STEP 6 (Rollback Gate) and offer options.
You can also check the Docker logs manually:

```bash
docker-compose logs --tail=50
```

### Reset a failed session

If you want to start completely fresh:

```bash
rm -f session/session_state.json
# Then start a new Gemini session
```

---

*For more information, see the [AAOF README](../../README.md) or open an issue on
[GitHub](https://github.com/ssignori76/Agnostic-Agent-Orchestrator-Framework-AAOF-).*
