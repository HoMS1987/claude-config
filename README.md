# claude-config

Personal configuration for [Claude Code](https://claude.com/claude-code) on Windows: global rules, settings and a custom status line.

## Contents

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Global rules that apply in every project (in German) |
| `rules/` | Further rules, one file per topic (see below) |
| `settings.json` | Settings and enabled plugins |
| `statusline.ps1` | Status line |
| `install.ps1` | Installs everything into `~/.claude` |

## Rules

Claude Code loads every file in `~/.claude/rules/` in every project. Files with `paths:` in their front matter only apply to matching files. The rules themselves are written in German.

| File | Content |
|------|---------|
| `destructive-actions-confirmation.md` | Always ask before deleting, `git reset --hard`, force pushes etc.; back up hand-edited files before regenerating them |
| `software-installation.md` | Install software only after asking, stating whether it adds autostart entries or services |
| `bugfix-tdd-first.md` | Bug fixes only with a 5-why analysis and a failing test first |
| `adr-architecture-decisions.md` | Architecture decisions as ADRs in `docs/adrs/` |
| `adler-communication-style.md` | Tone for texts other people read (PRs, issues, docs) |
| `utf8-umlaut-handling.md` | Always write umlauts directly, never replace them automatically |
| `commit-conventions.md` | `[TYPE] [#Issue] Description` in English, branch names, squash merge |
| `code-comments.md` | Code comments always in English, including doc comments and tests |
| `git-identity.md` | Git identity per repository, never the real name or a private address from the global Git config |
| `pull-requests.md` | PRs against `dev` in English, description covers the whole branch |
| `subagent-tool-discipline.md` | Tell sub-agents which skills and tools to use |
| `documentation-standards.md` | Markdown and documentation conventions, README on GitHub always in English, documents in third-party repositories in the repository's language (only `*.md`, `docs/`) |
| `dotnet-csharp-conventions.md` | C# language features, test stack (only `*.cs`, `*.csproj`, `*.sln`) |
| `dotnet-core-principles.md` | SOLID, Clean Architecture, TDD, review checklist (only .NET files) |

## Status line

```
~\projects\myrepo | ⎇ main* ↑2 ↓1 | ███░░░░░░░ 33% | Opus 5.5 | 5h 22% ↻ 19:00 7d 11%
```

- **Folder:** the home directory becomes `~`; paths longer than 40 characters are shortened to the last two levels.
- **Git:** branch (the short commit hash on a detached HEAD), `*` for uncommitted changes, `↑`/`↓` for commits ahead of/behind the upstream. Only shown inside a repository.
- **Context window:** usage, green below 50 %, yellow from 50 %, red from 80 %.
- **Model:** the currently active model.
- **Usage limits:** usage of the 5-hour and the weekly limit, plus the time at which the 5-hour window resets. Only shown when Claude Code provides the values (subscription).

## Requirements

- Windows with [PowerShell 7](https://learn.microsoft.com/powershell/) (`pwsh`)
- Git in `PATH`
- A terminal with a UTF-8 capable font (e.g. Windows Terminal)

## Installation

```powershell
git clone <URL of this repository>
cd claude-config
./install.ps1
```

The script

- aborts immediately if `~/.claude/.no-claude-config-install` exists (see below),
- copies `CLAUDE.md` and `statusline.ps1` into `~/.claude` and the rules into `~/.claude/rules`,
- merges the keys from `settings.json` into the existing `~/.claude/settings.json` (values from the repository win, all other settings are kept),
- asks whether the warning shown when starting “bypass permissions” mode should be skipped permanently (`skipDangerousModePermissionPrompt`),
- backs up every file it changes as `*.bak-<timestamp>` first.

It can be run any number of times.

| Parameter | Meaning |
|-----------|---------|
| `-ClaudeDir <path>` | Target directory other than `~/.claude` |
| `-SkipDangerousModePrompt yes\|no\|ask` | Answer the question in advance. The default is `ask`; without an interactive console the existing value stays unchanged. |

## Tests

```powershell
./tests/install.Tests.ps1
```

Runs `install.ps1` against temporary directories and exits with code 1 if a test fails. No test framework is required.

## Notes

- `CLAUDE.md` replaces an existing file of the same name (after a backup). If you have your own rules, merge the contents by hand.
- In `~/.claude/rules` only files with the same name are replaced (after a backup). Other rules there stay untouched.
- Machines whose configuration the script must never touch get an empty file `~/.claude/.no-claude-config-install`. The script then aborts before changing anything:

  ```powershell
  New-Item -ItemType File ~/.claude/.no-claude-config-install
  ```
- The plugins in `settings.json` come from the official marketplace; Claude Code loads them on the next start.
- The repository deliberately contains no credentials, conversation histories or memory files.
