# claude-config

Persönliche Konfiguration für [Claude Code](https://claude.com/claude-code) unter Windows: globale Regeln, Einstellungen und eine eigene Statusleiste.

## Inhalt

| Datei | Zweck |
|-------|-------|
| `CLAUDE.md` | Globale Regeln, die in jedem Projekt gelten (auf Deutsch) |
| `rules/` | Weitere Regeln, je Thema eine Datei (siehe unten) |
| `settings.json` | Einstellungen und aktivierte Plugins |
| `statusline.ps1` | Statusleiste |
| `install.ps1` | Installiert alles nach `~/.claude` |

## Regeln

Claude Code lädt jede Datei aus `~/.claude/rules/` in jedem Projekt. Dateien mit `paths:` im Kopf gelten nur für passende Dateien.

| Datei | Inhalt |
|-------|--------|
| `destructive-actions-confirmation.md` | Vor Löschen, `git reset --hard`, Force-Push usw. immer nachfragen |
| `bugfix-tdd-first.md` | Bugfix nur mit 5-Why-Analyse und zuerst rotem Test |
| `adr-architecture-decisions.md` | Architekturentscheidungen als ADR in `docs/adrs/` |
| `adler-communication-style.md` | Ton für Texte, die andere lesen (PRs, Issues, Doku) |
| `utf8-umlaut-handling.md` | Umlaute immer direkt schreiben, nie automatisch ersetzen |
| `commit-conventions.md` | `[TYPE] [#Issue] Beschreibung`, Branch-Namen, Squash-Merge |
| `git-identity.md` | Identität pro Repository, nie Klarname oder private Adresse aus der globalen Git-Konfiguration |
| `pull-requests.md` | PRs gegen `dev`, Beschreibung über den ganzen Branch |
| `subagent-tool-discipline.md` | Sub-Agents vorhandene Skills und Tools nennen |
| `documentation-standards.md` | Markdown- und Doku-Konventionen (nur `*.md`, `docs/`) |
| `dotnet-csharp-conventions.md` | C#-Sprachfeatures, Test-Stack (nur `*.cs`, `*.csproj`, `*.sln`) |
| `dotnet-core-principles.md` | SOLID, Clean Architecture, TDD, Review-Checkliste (nur .NET-Dateien) |

## Statusleiste

```
~\projekte\meinrepo | ⎇ main* ↑2 ↓1 | ███░░░░░░░ 33% | Opus 5.5 | 5h 22% ↻ 19:00 7d 11%
```

- **Ordner:** Home wird zu `~`, Pfade über 40 Zeichen werden auf die letzten zwei Ebenen gekürzt.
- **Git:** Branch (bei detached HEAD der kurze Commit-Hash), `*` bei uncommitteten Änderungen, `↑`/`↓` für Commits vor/hinter dem Upstream. Erscheint nur in einem Repository.
- **Kontextfenster:** Füllstand, grün unter 50 %, gelb ab 50 %, rot ab 80 %.
- **Modell:** das aktuell aktive Modell.
- **Nutzungslimits:** Verbrauch des 5-Stunden- und des Wochenlimits sowie die Uhrzeit, zu der das 5-Stunden-Fenster zurückgesetzt wird. Erscheint nur, wenn Claude Code die Werte liefert (Abo).

## Voraussetzungen

- Windows mit [PowerShell 7](https://learn.microsoft.com/powershell/) (`pwsh`)
- Git im `PATH`
- Ein Terminal mit UTF-8-fähiger Schrift (z. B. Windows Terminal)

## Installation

```powershell
git clone <URL dieses Repositories>
cd claude-config
./install.ps1
```

Das Skript

- bricht sofort ab, wenn `~/.claude/.no-claude-config-install` existiert (siehe unten),
- kopiert `CLAUDE.md` und `statusline.ps1` nach `~/.claude` und die Regeln nach `~/.claude/rules`,
- mischt die Schlüssel aus `settings.json` in die vorhandene `~/.claude/settings.json` ein (Werte aus dem Repository gewinnen, alle übrigen Einstellungen bleiben erhalten),
- fragt, ob der Warnhinweis beim Start des Modus „bypass permissions“ dauerhaft übersprungen werden soll (`skipDangerousModePermissionPrompt`),
- sichert jede Datei, die es ändert, vorher als `*.bak-<Zeitstempel>`.

Es kann beliebig oft ausgeführt werden.

| Parameter | Bedeutung |
|-----------|-----------|
| `-ClaudeDir <Pfad>` | Anderes Zielverzeichnis als `~/.claude` |
| `-SkipDangerousModePrompt yes\|no\|ask` | Die Abfrage vorab beantworten. Standard ist `ask`; ohne interaktive Konsole bleibt der vorhandene Wert unverändert. |

## Hinweise

- `CLAUDE.md` überschreibt eine vorhandene Datei gleichen Namens (nach Sicherung). Wer eigene Regeln hat, sollte die Inhalte von Hand zusammenführen.
- In `~/.claude/rules` werden nur gleichnamige Dateien ersetzt (nach Sicherung). Andere Regeln dort bleiben unberührt.
- Rechner, deren Konfiguration das Skript nie anfassen soll, bekommen eine leere Datei `~/.claude/.no-claude-config-install`. Dann bricht das Skript ab, bevor es etwas ändert:

  ```powershell
  New-Item -ItemType File ~/.claude/.no-claude-config-install
  ```
- Die Plugins in `settings.json` stammen aus dem offiziellen Marketplace und werden von Claude Code beim nächsten Start nachgeladen.
- Das Repository enthält bewusst keine Anmeldedaten, Gesprächsverläufe oder Memory-Dateien.
