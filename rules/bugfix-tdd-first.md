# Bugfix-Workflow: TDD-First ist Pflicht

Bei **jedem** Bugfix gilt diese Reihenfolge. Keine Ausnahmen, auch nicht für „triviale“ Einzeiler.

```
1. Bug reproduzieren
2. 5-Why-Analyse zur Root Cause
3. Failing Test schreiben (RED), der den Bug beweist
4. Fix implementieren (GREEN)
5. Refactoring (optional, Tests bleiben grün)
6. Commit: Test und Fix zusammen, 5-Why-Kette im Commit-Body
```

## 5-Why-Analyse

Vor jedem Fix die Ursache mit aufeinanderfolgenden Warum-Fragen zurückverfolgen. Ziel ist die
eigentliche Ursache, nicht das Symptom.

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

- **Fünf ist ein Richtwert.** Weitergraben, solange die Antwort technisch ist; erst stoppen, wenn
  sie auf eine Prozess- oder Struktur-Ursache zeigt.
- **Mehrere Ursachen sind erlaubt.** Endet die Kette in zwei Pfaden, werden beide gefixt.
- **Der Fix adressiert die tiefste Ursache**, nicht das oberste Symptom.
- **Die Kette wird dokumentiert**: im Commit-Body, in der Analyse oder im Issue-/PR-Kommentar.
- Gilt auch für Analysen von Legacy-Code und für Review-Findings der Stufe CRITICAL/WARNING.

## Commit-Format

```
[BUGFIX] Short description of the fix

Cause: [what caused the bug]
5-Why: [one-sentence summary of the deepest cause found]
Test: [name of the new test case]
```

## Verboten

- Test nach dem Fix schreiben (dann beweist er nichts)
- Bestehende Tests anpassen, damit der Bug „verschwindet“

## Ausnahme

Ist ein Test technisch nicht möglich (z. B. reiner UI-Bug, Infrastruktur-Problem): begründen, warum,
und fragen, ob der Fix ohne Test akzeptabel ist.
