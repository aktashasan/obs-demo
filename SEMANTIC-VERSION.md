# Semantic Versioning Guide

## Overview

This project uses **Semantic Versioning (SemVer)** with **Conventional Commits** to automatically manage version numbers.

## How It Works

When you push to `main` branch, the GitHub Actions workflow:

1. Analyzes your commit message
2. Determines the version bump type
3. Updates `pom.xml` automatically
4. Creates a git tag (e.g., `v1.2.0`)
5. Deploys to GitHub Packages

## Version Bump Rules

| Commit Type | Version Bump | Example |
|-------------|-------------|---------|
| `feat:` | **Minor** | `1.1.0` → `1.2.0` |
| `fix:` | **Patch** | `1.1.0` → `1.1.1` |
| `perf:` | **Patch** | `1.1.0` → `1.1.1` |
| `chore:`, `docs:`, `style:`, `refactor:`, `test:` | **Patch** | `1.1.0` → `1.1.1` |
| `feat!:`, `fix!:` or `BREAKING CHANGE:` | **Major** | `1.1.0` → `2.0.0` |

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Examples

**Feature (Minor bump):**

```bash
git commit -m "feat: add user authentication"
# Result: 1.1.0 → 1.2.0
```

**Bug Fix (Patch bump):**

```bash
git commit -m "fix: resolve login timeout issue"
# Result: 1.1.0 → 1.1.1
```

**Breaking Change (Major bump):**

```bash
git commit -m "feat!: redesign API endpoints

BREAKING CHANGE: API endpoints have been completely restructured"
# Result: 1.1.0 → 2.0.0
```

**Chore/Docs (Patch bump):**

```bash
git commit -m "chore: update dependencies"
# Result: 1.1.0 → 1.1.1
```

## Workflow Breakdown

### 1. Determine Version

- Fetches latest git tag (e.g., `v1.1.0`)
- Analyzes commit message
- Calculates new version

### 2. Update Version

- Updates `pom.xml` with new version
- Commits change: `chore: bump version to X.Y.Z [type]`
- Creates and pushes git tag `vX.Y.Z`

### 3. Deploy

- Builds Maven package
- Runs tests
- Deploys to GitHub Packages

## Manual Override

To manually trigger with a specific version:

```bash
mvn versions:set -DnewVersion=2.0.0
git add pom.xml
git commit -m "chore: bump version to 2.0.0 [manual]"
git tag v2.0.0
git push origin main --tags
```

## First Time Setup

If no tags exist, workflow starts from `v1.0.0`:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Viewing Versions

**List all versions:**

```bash
git tag -l 'v*'
```

**Check current version:**

```bash
grep '<version>' pom.xml | head -1
```

**View on GitHub:**

- Releases: `/releases`
- Packages: `/packages`
- Tags: `/tags`

## Conventional Commit Types

| Type | Purpose | Version Impact |
|------|---------|---------------|
| `feat` | New feature | Minor |
| `fix` | Bug fix | Patch |
| `perf` | Performance improvement | Patch |
| `docs` | Documentation only | Patch |
| `style` | Code style (formatting, etc.) | Patch |
| `refactor` | Code refactoring | Patch |
| `test` | Adding/updating tests | Patch |
| `chore` | Maintenance tasks | Patch |
| `ci` | CI/CD changes | Patch |
| `build` | Build system changes | Patch |

## Best Practices

1. **Always use conventional commits** for clarity
2. **Include scope** when relevant: `feat(auth): add OAuth2`
3. **Write clear descriptions**: what changed and why
4. **Use breaking change footer** for major changes
5. **Keep commits atomic**: one logical change per commit

## Troubleshooting

**409 Conflict error:**

- Version already exists in GitHub Packages
- Workflow will auto-increment, don't manually use same version

**Tag already exists:**

- Delete tag: `git tag -d vX.Y.Z`
- Delete remote tag: `git push origin :refs/tags/vX.Y.Z`
- Push again

**Wrong version calculated:**

- Check commit message format
- Ensure using conventional commit types
- Manually override if needed
