---
paths:
  - "**/*.md"
  - "**/README*"
  - "**/docs/**"
---

# Dokumentations-Standards

## Markdown-Konventionen

- **Keine horizontalen Linien** (`---`) verwenden — Überschriften statt Trennlinien

## README auf GitHub: immer Englisch

- Liegt ein Repository auf GitHub, ist das `README.md` **immer auf Englisch**, auch wenn die übrige
  Doku (`docs/`, ADRs) oder die Oberfläche deutsch ist.
- Ein bestehendes deutsches README wird beim nächsten Anfassen vollständig übersetzt, nicht gemischt.

## Fremde Repositories: Sprache des Repositories

- In fremden Repositories (Upstream, Projekte anderer) sind Dokumente **immer in der Sprache des
  Repositories** geschrieben: README, `docs/`, ADRs, Changelogs und alle übrigen Markdown-Dateien.
- Die Sprache ergibt sich aus der vorhandenen Doku. Ist sie gemischt oder unklar: nachfragen.
- Das geht allen anderen Sprachregeln vor, auch „README auf GitHub: immer Englisch“.

## Code-Dokumentation

- XML-Kommentare für öffentliche APIs
- README.md pro Projekt: Beschreibung, Setup, Beispiele, Limitationen

## Architektur-Dokumentation

- `docs/architecture.md` für Architekturbeschreibung
- API-Dokumentation mit Swagger/OpenAPI
- Datenbank-Schema-Dokumentation
