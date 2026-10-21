# Code-Kommentare: immer auf Englisch

## Regel

Kommentare im Code werden **immer auf Englisch** geschrieben. Das gilt für:

- Zeilen- und Blockkommentare
- Doc-Kommentare (PHPDoc, JSDoc/TSDoc, XML-Dokumentation in C#)
- `WHY:`-, `TODO:`- und ähnliche Markierungen
- Kommentare in Tests

Das gilt auch, wenn Doku, Oberfläche oder die Unterhaltung deutsch sind.

## Bestehender Code

- Neue Kommentare: Englisch.
- Wird ein vorhandener deutscher Kommentar angepasst: dabei ins Englische übersetzen.
- Ist ein Projekt komplett mit deutschen Kommentaren entstanden: die Umstellung aller Kommentare
  als eigene Aufgabe einplanen (eigener Commit, `[STYLE]`), statt sie nebenbei zu mischen.

## Nicht betroffen

- Texte für Nutzer (Oberfläche, Übersetzungsdateien, Fehlermeldungen für Endnutzer) folgen der
  Sprache des Produkts.
- Dokumentation in Markdown (README, ADRs, `docs/`) folgt der Sprache des Projekts.
- Bezeichner sind ohnehin englisch.
