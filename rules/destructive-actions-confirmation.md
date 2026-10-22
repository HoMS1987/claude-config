# Destruktive Aktionen: immer Bestätigung einholen

Vor jeder destruktiven Aktion **immer** ausdrücklich nachfragen und auf ein „ja“ warten.
**Keine Ausnahmen**, auch nicht für „offensichtlich“ temporäre Dateien, Build-Artefakte, Caches
oder Dateien, die „sowieso neu generiert werden“.

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

Ist unklar, ob eine Aktion destruktiv ist: fragen.

## Vorgehen

1. Beschreiben, was gelöscht oder geändert wird, und die betroffenen Dateien/Ordner auflisten
2. Fragen: „Soll ich [Aktion] ausführen?“, wo sinnvoll mit Alternative oder Backup-Option
3. Erst nach „ja“ ausführen

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
