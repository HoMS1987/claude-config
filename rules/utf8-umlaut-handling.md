# UTF-8 und deutsche Umlaute

## Umlaute immer direkt schreiben

Deutsche Texte enthalten immer ä, ö, ü und ß, nie Ersatzschreibweisen wie „ae“, „oe“, „ue“ oder „ss“
(außer bei Großschreibung). Das gilt überall, auch in:

- JSON, API-Aufrufen (`gh`, curl, jq) und Shell-Variablen
- Zwischendateien, deren Inhalt später an eine API geht (PR-Texte, Issues, Kommentare).
  Sie landen 1:1 auf GitHub.

Bash, PowerShell, Python, curl, jq und alle APIs arbeiten mit UTF-8. Es gibt keinen technischen
Grund, Umlaute zu vermeiden. Der Reflex, in Shell- oder Dateikontext ASCII-sicher zu schreiben,
ist falsch.

## Nie automatisch ersetzen

Keine Skripte oder Regex, die `ae→ä`, `oe→ö`, `ue→ü` ersetzen. Sie zerstören englische Wörter und
Bezeichner: `Queue` → `Qüue`, `QueryType` → `QüryType`, `true` → `trü`.

Ist unklar, ob ein Wort deutsch oder englisch ist: nicht ersetzen, im Zweifel nachfragen.

Dateinamen enthalten keine Umlaute.
