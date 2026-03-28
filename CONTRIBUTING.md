# Contributing to AAOF

Thank you for your interest in contributing to the **Agnostic Agent Orchestrator
Framework (AAOF)**! This is a public project and all contributions are welcome.

---

## 📋 Before You Start

- Read the [README.md](README.md) to understand the project's vision and structure.
- Read [agent.md](agent.md) to understand the framework's core workflow.
- Check [existing issues](https://github.com/ssignori76/Agnostic-Agent-Orchestrator-Framework-AAOF-/issues)
  to avoid duplicating work.

---

## 🌿 Branch Strategy

- `main` — Stable, production-ready state. Never commit directly.
- `feature/<name>` — New features or enhancements (e.g., `feature/claude-guide`).
- `fix/<name>` — Bug fixes (e.g., `fix/docker-healthcheck`).
- `docs/<name>` — Documentation-only changes.

Always create a new branch from `main` for your contribution.

---

## 🔄 Pull Request Process

1. **Fork** the repository and create your branch from `main`.
2. **Make your changes** following the guidelines below.
3. **Test your changes** — if your change involves templates or rules, verify them
   manually with a sample project.
4. **Update documentation** — update `README.md` or relevant `rules/` files if needed.
5. **Update `changelog.md`** — add an entry under `[Unreleased]`.
6. **Open a Pull Request** with a clear title and description of what you changed and why.

---

## ✅ Contribution Guidelines

### Rules Files (`rules/*.md`)

- Keep them actionable and specific — avoid vague principles.
- Use tables, code examples, and numbered steps for clarity.
- Maximum 300 lines per file (see `rules/development_rules.md`).
- All rules must be technology-agnostic where possible.

### Templates (`templates/`)

- Templates must be well-commented — they are read by AI agents and humans alike.
- Include a header comment with `Purpose:` and `Usage:`.
- Use placeholder values that are clearly recognizable (e.g., `my-project`, `CHANGE_ME`).

### Documentation (`docs/`)

- Guides must be step-by-step and beginner-friendly (the target audience includes
  non-programmers).
- Include screenshots or code blocks for every non-obvious step.
- Test all commands before documenting them.

### Core Files (`agent.md`, `README.md`)

- Changes to `agent.md` must preserve backward compatibility with existing sessions.
- Discuss significant workflow changes in an issue first.
- `README.md` is the project's public face — keep it professional and welcoming.

---

## 🐛 Reporting Issues

When reporting a bug or requesting a feature:

- Use the GitHub issue tracker.
- For bugs: describe what you expected, what happened, and include relevant logs.
- For features: describe the use case and how the feature would help.
- Label your issue appropriately: `bug`, `enhancement`, `documentation`, `question`.

---

## 📄 License

By contributing to AAOF, you agree that your contributions will be licensed under
the [MIT License](LICENSE).

---

*Thank you for helping make AAOF better for everyone!* 🚀
