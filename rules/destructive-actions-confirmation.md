# Destruktive Aktionen: IMMER Bestätigung einholen

## KRITISCHE REGEL - NIEMALS BRECHEN

**BEVOR** destruktive Aktionen ausgeführt werden, **MUSS IMMER** eine explizite Bestätigung vom Benutzer eingeholt werden. **KEINE AUSNAHMEN.**

## Betroffene Aktionen

| Kategorie | Befehle/Aktionen |
|-----------|------------------|
| Dateien löschen | `rm`, `rm -rf`, `unlink`, `del` |
| Ordner löschen | `rmdir`, `rm -r`, `rd /s` |
| Git destruktiv | `git clean`, `git reset --hard`, `git checkout -- .`, `git restore .` |
| Git History | `git push --force`, `git rebase` (auf shared branches) |
| Datenbank | `DROP`, `DELETE`, `TRUNCATE` |
| Überschreiben | Dateien überschreiben ohne Backup, auch durch ein Skript, das sie neu erzeugt |
| Prozesse | `kill -9`, `pkill`, Prozesse beenden |

## Von Hand bearbeitete Dateien neu erzeugen

Ergebnisdateien wie `.pptx`, `.docx` oder `.xlsx` bearbeitet der Benutzer oft zwischen zwei Anfragen
direkt in Office. Ein Skript, das die Datei neu erzeugt, überschreibt diese Änderungen still, denn
sein Inhalt stammt vom letzten Generieren.

1. Vor dem Neuerzeugen die vorhandene Datei immer mit Zeitstempel sichern
   (`<name>.backup-YYYYMMDD-HHMMSS.<ext>`). Das gilt auch ohne Rückfrage.
2. Prüfen, ob die Datei seit dem letzten Generieren geändert wurde (Änderungszeit, Inhalt vergleichen).
3. Wurde sie geändert: nicht neu erzeugen, sondern nachfragen. Die Änderungen entweder ins Skript
   übernehmen oder die Datei gezielt bearbeiten statt neu zu erzeugen.

Nicht darauf verlassen, dass Papierkorb, Schattenkopien, Dateiversionsverlauf oder OneDrive die alte
Fassung noch haben.

## Verbotene Vorgehensweise

```bash
# ❌ NIEMALS so:
rm -rf /path/to/folder

# ❌ NIEMALS so:
git clean -fd

# ❌ NIEMALS so:
git checkout -- .
```

## Korrekte Vorgehensweise

```markdown
# ✅ IMMER so:

1. Beschreibe was gelöscht/geändert werden soll
2. Liste die betroffenen Dateien/Ordner auf
3. Frage explizit: "Soll ich [Aktion] ausführen? (ja/nein)"
4. Warte auf Bestätigung
5. Erst NACH "ja" die Aktion ausführen
```

## Beispiel-Dialog

```
Claude: "Folgende Ordner würden gelöscht werden:
- src/Legacy/
- tools/old-scripts/
- docs/drafts/

Soll ich diese drei Ordner löschen?"

User: "ja"

Claude: [führt rm -rf aus]
```

## Ausnahmen

**KEINE.** Auch nicht bei:
- "offensichtlich" temporären Dateien
- Build-Artefakten
- Cache-Ordnern
- Dateien die "sowieso neu generiert werden"

**IMMER FRAGEN.**

## Warum?

- Gelöschte Daten sind oft unwiederbringlich
- Untracked Git-Dateien haben kein Backup
- Der Benutzer kennt den Kontext besser
- Vorsicht ist besser als Datenverlust

## Bei Unsicherheit

Wenn unklar ist ob eine Aktion destruktiv ist:
1. Lieber einmal zu viel fragen
2. Alternativen vorschlagen (z.B. `.gitignore` statt löschen)
3. Backup-Option anbieten
