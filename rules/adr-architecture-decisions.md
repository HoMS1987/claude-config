# Architecture Decision Records (ADRs)

## Pflicht-Konvention

**Jedes Projekt MUSS** Architecture Decision Records in `/docs/adrs/` ablegen.

## Verzeichnisstruktur

```
project-root/
└── docs/
    └── adrs/
        ├── 0001-use-event-sourcing.md
        ├── 0002-graphql-over-rest.md
        ├── 0003-martendb-as-event-store.md
        └── template.md
```

## ADR-Format (Michael Nygard Template)

```markdown
# [Nummer]. [Titel der Entscheidung]

Datum: YYYY-MM-DD

## Status

[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

## Kontext

[Beschreibung der Situation und des Problems]

## Entscheidung

[Die getroffene Entscheidung]

## Konsequenzen

[Positive und negative Auswirkungen der Entscheidung]
```

## Nummerierung

- Format: `NNNN-kurze-beschreibung.md`
- Beispiel: `0001-use-event-sourcing.md`
- Fortlaufend, niemals Nummern wiederverwenden

## Wann ADRs erstellen

- ✅ Technologie-Entscheidungen (Framework, Library, Datenbank)
- ✅ Architektur-Patterns (CQRS, Event Sourcing, Clean Architecture)
- ✅ API-Design-Entscheidungen (REST vs GraphQL, Versionierung)
- ✅ Sicherheits-Entscheidungen (Auth-Methode, Encryption)
- ✅ Infrastruktur-Entscheidungen (Cloud, Container, Deployment)

## Review-Pflicht

Bei Code-Reviews und automatisierten Reviews **MUSS** gegen bestehende ADRs geprüft werden:
- Verstößt der Code gegen eine ADR? → CRITICAL
- Weicht der Code ohne Begründung ab? → WARNING
- Fehlt eine ADR für eine neue Architektur-Entscheidung? → INFO
