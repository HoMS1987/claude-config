# claude-config

Persönliche Konfiguration für [Claude Code](https://claude.com/claude-code) unter Windows: globale Regeln, Einstellungen und eine eigene Statusleiste.

## Inhalt

| Datei | Zweck |
|-------|-------|
| `CLAUDE.md` | Globale Regeln, die in jedem Projekt gelten (auf Deutsch) |
| `settings.json` | Einstellungen und aktivierte Plugins |
| `statusline.ps1` | Statusleiste |
| `install.ps1` | Installiert alles nach `~/.claude` |

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

- kopiert `CLAUDE.md` und `statusline.ps1` nach `~/.claude`,
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
- Die Plugins in `settings.json` stammen aus dem offiziellen Marketplace und werden von Claude Code beim nächsten Start nachgeladen.
- Das Repository enthält bewusst keine Anmeldedaten, Gesprächsverläufe oder Memory-Dateien.
