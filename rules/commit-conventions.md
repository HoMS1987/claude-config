# Commit- und Branch-Konvention

## Commit-Message

Erste Zeile: Typ in eckigen Klammern, optional die Issue-Nummer, dann eine
Beschreibung, die das Ergebnis der Analyse nennt — nicht das Symptom.

```
[TYPE] [#Issue] Beschreibung
```

```
# ❌ FALSCH
[BUGFIX] Durchschnitt funktioniert nicht

# ✅ RICHTIG
[BUGFIX] [#42] Durchschnittsberechnung behandelt leere Messreihen, statt durch null zu teilen
```

Weitere Zeilen (Body) erklären bei Bedarf das Warum. Für Bugfixes gilt
zusätzlich das Format aus `bugfix-tdd-first.md` (Ursache, 5-Why, Test).

## Typen

| Typ | Wofür | Branch |
|-----|-------|--------|
| `FEATURE` | Neue Funktion oder deutliche Erweiterung | `feature/<issue>-<slug>` |
| `BUGFIX` | Fehlerbehebung | `bugfix/<issue>-<slug>` |
| `DOCS` | Nur Dokumentation (README, Kommentare) | `docs/…` |
| `STYLE` | Formatierung ohne Logikänderung | `style/…` |
| `REFACTOR` | Strukturverbesserung ohne neues Verhalten | `refactor/…` |
| `PERF` | Performance-Verbesserung | `perf/…` |
| `TEST` | Tests hinzufügen oder ändern | `test/…` |
| `CHORE` | Wartung, Abhängigkeiten aktualisieren | `chore/…` |
| `CI` | CI/CD-Konfiguration, Dockerfiles, Deploy-Skripte | `ci/…` |
| `BUILD` | Build-System, NuGet-/npm-Pakete, Compiler-Flags | `build/…` |
| `REVERT` | Macht einen früheren Commit rückgängig | `revert/…` |

Ohne Issue entfällt die Nummer im Branch-Namen (`feature/<slug>`).

## Ablauf

1. Branch vom Ziel-Branch abzweigen (siehe `pull-requests.md`)
2. Vor dem PR den Ziel-Branch per `git rebase` nachziehen — lineare Historie
3. PR als **Squash-Merge** abschließen: ein Commit pro Branch im Ziel-Branch
