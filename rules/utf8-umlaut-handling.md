# UTF-8 und Deutsche Umlaute: Korrekte Handhabung

## KRITISCHE REGEL - NIEMALS BRECHEN

### 1. JSON ist IMMER UTF-8

**Alle APIs akzeptieren UTF-8.** Es gibt KEINEN Grund, jemals auf ASCII-Ersatzschreibweisen zurückzufallen.

```json
// RICHTIG — UTF-8 direkt verwenden
{"summary": "Prüfung der Überblick-Seite für Änderungen"}

// FALSCH — ASCII-Ersatzschreibweisen
{"summary": "Pruefung der Ueberblick-Seite fuer Aenderungen"}
```

Das gilt für: GitHub API (`gh`), REST-APIs allgemein, curl, jq — ALLE.

### 2. NIEMALS automatische Umlaut-Ersetzung

**VERBOTEN**: Skripte oder Regex die blind `ae→ä`, `oe→ö`, `ue→ü` ersetzen.

Warum? Englische und technische Begriffe werden zerstört:
- `QueryType` → `QüryType` (FALSCH!)
- `Queue` → `Qüue` (FALSCH!)
- `Blueprint` → `Blüprint` (FALSCH!)
- `true` → `trü` (FALSCH!)
- `sequel` → `seqül` (FALSCH!)

### 3. Umlaute von Anfang an korrekt schreiben

**Claude MUSS deutsche Umlaute direkt verwenden** — nicht erst `ue` schreiben und dann ersetzen lassen.

| Kontext | Beispiel | Regel |
|---------|----------|-------|
| Deutsche Wörter | für, über, Änderung, Prüfung | Immer ä, ö, ü, ß |
| Englische Wörter | Queue, Query, true, value | Niemals ersetzen |
| Code-Bezeichner | ProcessDataQueryType | Englisch, niemals ersetzen |
| CamelCase | SubstrateTracking | Englisch, niemals ersetzen |
| Dateinamen | settings.toml, NuGet.Config | Keine Umlaute (Konvention) |

### 4. Bei Unsicherheit: NICHT ersetzen

Wenn unklar ist ob ein Wort deutsch oder englisch ist:
- **Nicht ersetzen** — lieber ein fehlendes ü als ein kaputtes Wort
- Im Zweifel den User fragen

### 5. Datei-Inhalte für APIs: Umlaute SOFORT korrekt schreiben

**KRITISCH**: Wenn Dateien geschrieben werden, deren Inhalt an eine API gesendet wird (Issue- und PR-Beschreibungen, Kommentare, Dokumentationsseiten), dann gelten dieselben Umlaut-Regeln wie für direkte API-Calls.

**Root Cause**: Der Shell/Python-Kontext verleitet unbewusst zu ASCII-sicheren Schreibweisen. Wenn ein Text in einer `.txt`-Datei oder als Shell-Variable geschrieben wird, greift ein falscher Reflex zu "oe" statt "ö". **Dieser Reflex ist FALSCH** — Bash, Python, curl, jq und alle APIs arbeiten nativ mit UTF-8. Es gibt keinen technischen Grund, Umlaute zu vermeiden.

**Häufiger Fehler**: Temporäre Dateien (z.B. `/tmp/pr-body-*.md`) werden ohne Umlaute geschrieben, weil sie "nur Zwischendateien" sind. **FALSCH** — der Inhalt landet 1:1 auf GitHub!

```
# FALSCH — ASCII in Zwischendatei
"Angenommen der Bestaetungsdialog ist geoeffnet"
"Loeschen bestaetigt"

# RICHTIG — Umlaute direkt
"Angenommen der Bestätigungsdialog ist geöffnet"
"Löschen bestätigt"
```

**Checkliste vor dem Schreiben deutscher Texte:**
- [ ] Alle ä, ö, ü, ß korrekt?
- [ ] Kein "oe" statt "ö", kein "ue" statt "ü", kein "ae" statt "ä"?
- [ ] Kein "ss" statt "ß" (außer bei Großschreibung)?
