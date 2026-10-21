# Bugfix-Workflow: TDD-First ist PFLICHT

## KRITISCHE REGEL - IMMER EINHALTEN

Bei **JEDEM Bugfix** MUSS der TDD-Workflow eingehalten werden. Keine Ausnahmen.

## Pflicht-Reihenfolge

```
1. Bug reproduzieren (verstehen was passiert)
2. 5-Why-Analyse zur Root Cause (siehe unten) — PFLICHT bei jedem Bug
3. Failing Test schreiben (RED) — beweist den Bug
4. Fix implementieren (GREEN) — Test muss grün werden
5. Refactoring (REFACTOR) — optional, Tests bleiben grün
6. Commit: Test + Fix ZUSAMMEN, 5-Why-Kette im Commit-Body
```

## 5-Why-Analyse zur Root Cause (PFLICHT)

Vor jedem Fix wird die Ursache systematisch mit **5 aufeinanderfolgenden
Warum-Fragen** zurückverfolgt. Ziel: nicht das Symptom behandeln, sondern
die eigentliche Ursache finden — die oft eine Ebene über dem ersten
Erklärungsversuch liegt.

**Beispiel:**

```
Beobachtung: TOC enthält Heading aus einem Code-Block.

1. Warum? Regex matcht `^#` auch innerhalb fenced Code-Blöcken.
2. Warum ist der Regex so formuliert? Es wurde kein Parser verwendet.
3. Warum kein Parser? Scope wurde als "nur Headings" gesehen.
4. Warum keine Tests, die das gefunden hätten? Keine Tests existieren.
5. Warum keine Tests? Projekt hat kein Test-Projekt angelegt.

→ Root Cause: fehlende Test-Infrastruktur, nicht der Regex.
→ Fix umfasst: Parser-Library + Test-Projekt + Regressionstests.
```

**Regeln:**

- **Fünf ist ein Richtwert**, keine starre Zahl — manche Bugs brauchen
  drei Why-Fragen, andere sieben. Wichtig ist: weitergraben, solange die
  Antwort noch technisch ist, und erst stoppen, wenn sie auf eine
  Prozess- oder Struktur-Ursache zeigt.
- **Die 5-Why-Kette wird dokumentiert** — entweder im Commit-Body, in
  der Analyse oder im Issue- bzw. PR-Kommentar zum Bug.
- **Mehrere Ursachen sind erlaubt**: manchmal endet die Kette in zwei
  Pfaden (z.B. „fehlender Test" **und** „fehlende Validierung"). Beide
  werden gefixt.
- **Der Fix adressiert die tiefste gefundene Ursache**, nicht das oberste
  Symptom. Im Beispiel oben: nicht „Regex austauschen", sondern
  „Test-Projekt einrichten + Parser einführen".

**Auch bei Analysen von Legacy-Code** und bei Review-Findings der
Stufe CRITICAL/WARNING wird die 5-Why-Methodik angewendet, damit der
Plan die echten Ursachen adressiert und nicht nur die sichtbaren Symptome.

## Warum?

| Ohne TDD-First | Mit TDD-First |
|-----------------|---------------|
| Fix ohne Beweis dass Bug existierte | Test beweist den Bug existierte |
| Regression kann jederzeit wiederkommen | Regression wird sofort durch Test erkannt |
| Kein Vertrauen dass Fix korrekt ist | Grüner Test beweist Korrektheit |
| Review kann Bug nicht nachvollziehen | Test dokumentiert das Fehlerszenario |

## Commit-Format

```
[BUGFIX] Short description of the fix

Cause: [what caused the bug]
5-Why: [one-sentence summary of the deepest cause found]
Test: [name of the new test case]
```

## Anti-Patterns

- **NIEMALS** einen Fix committen ohne zugehörigen Test
- **NIEMALS** den Test nach dem Fix schreiben (dann ist er kein Beweis)
- **NIEMALS** "triviale" Bugs als Ausnahme betrachten — auch Einzeiler-Fixes brauchen Tests
- **NIEMALS** bestehende Tests anpassen damit der Bug "verschwindet"

## Ausnahme

Nur wenn ein Test technisch nicht möglich ist (z.B. reiner UI-Bug, Infrastruktur-Problem):
1. Dokumentiere WARUM kein Test möglich ist
2. Frage den User ob der Fix ohne Test akzeptabel ist
