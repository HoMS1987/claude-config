# Software installieren: nur nach Absprache

## Regel

Programme, Pakete und Werkzeuge dürfen installiert werden, wenn es notwendig und sinnvoll ist,
aber **immer erst nach Rückfrage**. Fehlt ein Werkzeug, nicht still auf einen Umweg ausweichen
und nicht ungefragt installieren.

Das betrifft systemweite und benutzerweite Installationen (`winget`, Installer, `choco`, `scoop`,
globale `npm`-/`dotnet tool`-/`pip`-Pakete usw.), nicht Projektabhängigkeiten wie
`npm install` oder `dotnet restore` im Repository.

## Inhalt der Rückfrage

Jede Rückfrage nennt:

| Punkt | Beispiel |
|-------|----------|
| Was und wozu | „Node.js LTS, damit der Browser-Begleiter startet“ |
| Wie | `winget install OpenJS.NodeJS.LTS` |
| Autostart | Ob etwas im Autostart landet (Autostart-Ordner, `Run`-Schlüssel, geplante Aufgabe, Tray-Programm) |
| Dienst | Ob ein neuer Windows-Dienst oder Hintergrundprozess hinzukommt |
| Alternative | Was ohne Installation ginge, und was dabei fehlt |

Ist beim Autostart oder beim Dienst unklar, ob etwas hinzukommt, das ausdrücklich so sagen
und nicht „nein“ schreiben.
