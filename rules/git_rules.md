# Git & GitHub Rules

> **Purpose:** Version control strategy, branching model, commit conventions, tagging,
> and GitHub integration rules for projects managed by the Agnostic Orchestrator Agent.
>
> **Scope:** All projects with `version_control.enabled: true` in `config.json`.
> **Condition:** These rules are IGNORED if `version_control.enabled` is `false` or absent.

---

## 1. Branching Model

| Branch              | Purpose                              | Created From | Merges Into        |
| :------------------ | :----------------------------------- | :----------- | :----------------- |
| `main`              | Production-ready, stable releases    | —            | —                  |
| `develop`           | Integration branch for next release  | `main`       | `main`             |
| `feature/<name>`    | New feature development              | `develop`    | `develop`          |
| `fix/<name>`        | Bug fix                              | `develop`    | `develop`          |
| `hotfix/<name>`     | Urgent fix on production             | `main`       | `main` + `develop` |
| `release/<version>` | Release preparation & stabilization  | `develop`    | `main` + `develop` |

### Rules:
- **Never commit directly to `main` or `develop`.**
- Every change goes through a feature/fix branch → Pull Request → merge.
- Delete branches after merge.
- Branch names: lowercase, hyphens, max 50 chars. e.g., `feature/add-user-auth`.

---

## 2. Commit Conventions (Conventional Commits)

Every commit message MUST follow this format:

```
<type>(<scope>): <short description>

[optional body]

[optional footer(s)]
```

### Allowed Types

| Type       | Description                                              | Version Bump |
| :--------- | :------------------------------------------------------- | :----------- |
| `feat`     | A new feature                                            | MINOR        |
| `fix`      | A bug fix                                                | PATCH        |
| `docs`     | Documentation changes only                              | —            |
| `style`    | Formatting, missing semicolons, etc. (no logic change)  | —            |
| `refactor` | Code restructure without adding features or fixing bugs  | —            |
| `perf`     | Performance improvement                                  | PATCH        |
| `test`     | Adding or updating tests                                 | —            |
| `build`    | Build system or external dependency changes              | —            |
| `ci`       | CI/CD configuration changes                              | —            |
| `chore`    | Maintenance tasks (e.g., updating `.gitignore`)          | —            |
| `revert`   | Reverts a previous commit                                | PATCH        |

### Breaking Changes

Append `!` after the type/scope OR add `BREAKING CHANGE:` in the footer to trigger a
**MAJOR** version bump:

```
feat!: remove deprecated API endpoint

BREAKING CHANGE: The /api/v1/users endpoint has been removed. Use /api/v2/users instead.
```

### Examples

```
feat(auth): add JWT refresh token support
fix(db): resolve connection pool timeout on high load
docs(readme): update deployment instructions
refactor(api): extract validation logic into middleware
feat!: drop support for Node.js 16
```

### Rules:
- Short description: imperative mood, lowercase, no period at the end, max 72 chars.
- Body: wrap at 100 chars; explain *what* and *why*, not *how*.
- One logical change per commit — do not bundle unrelated changes.

---

## 3. Semantic Versioning (SemVer)

All releases follow **`MAJOR.MINOR.PATCH`** versioning:

| Component | When to increment                                        |
| :-------- | :------------------------------------------------------- |
| `MAJOR`   | Breaking changes (incompatible API changes)              |
| `MINOR`   | New backwards-compatible features (`feat` commits)       |
| `PATCH`   | Backwards-compatible bug fixes (`fix`, `perf`, `revert`) |

### Version Determination Rules:
1. Scan all commits since the last tag on the working branch.
2. If any commit has `BREAKING CHANGE` or `!` → bump MAJOR, reset MINOR and PATCH to 0.
3. Else if any `feat` commit exists → bump MINOR, reset PATCH to 0.
4. Else if any `fix`, `perf`, or `revert` commit exists → bump PATCH.
5. Store the resulting version in `VAR_CURRENT_VERSION` in `session_state.json`.

---

## 4. Tagging

- Tags MUST be **annotated** (not lightweight):
  ```
  git tag -a v<VERSION> -m "Release v<VERSION>"
  ```
- Tag format: `v<MAJOR>.<MINOR>.<PATCH>` — e.g., `v1.2.0`.
- Tags are created on `main` after the release branch is merged.
- Push tags explicitly: `git push origin v<VERSION>` or `git push --tags`.
- **Never delete or move a published tag.**
- If `auto_tag` is `true` in `config.json`, the agent creates the tag automatically at
  STEP 7 without additional user confirmation.

---

## 5. Pull Request Standards

Every merge to `develop` or `main` MUST go through a Pull Request:

### PR Title
Follow the same Conventional Commits format:
```
<type>(<scope>): <short description>
```

### PR Description Template
```markdown
## Summary
Brief description of the change.

## Changes
- List of specific changes made

## Testing
- How the change was tested

## Breaking Changes
- None / Description of breaking changes

## Related Issues
- Closes #<issue_number>
```

### Rules:
- At least one approval required before merging (when collaborating).
- All CI checks must pass before merging.
- Use **rebase and merge** to `develop` to preserve individual conventional commits
  (required for accurate SemVer bump detection). Use **merge commits** on merge to `main`.
- Link related issues in the PR description.

---

## 6. GitHub Artifacts & Releases

When `provider` is `github` in `config.json`:

- **GitHub Release:** Create a GitHub Release tied to the annotated tag.
  - Title: `Release v<VERSION>`
  - Body: auto-generated from commit messages since the last tag (changelog format).
- **Artifacts:** Attach build artifacts (Docker images, binaries, archives) to the
  GitHub Release when applicable.
- **GitHub Actions:** If a CI/CD workflow exists, ensure it passes before release.

---

## 7. Repository Hygiene

- **`.gitignore`:** Always maintain an up-to-date `.gitignore`. Never commit:
  - Secrets, credentials, or API keys
  - `node_modules/`, `vendor/`, `.venv/`, build artifacts (`dist/`, `build/`)
  - IDE/editor config files (`.idea/`, `.vscode/`) unless team-wide
  - Docker volumes and local data directories
- **No force push** to `main` or `develop` — ever.
- Keep commits atomic: one logical change per commit.
- Rebase feature branches on `develop` before opening a PR to avoid merge conflicts.
