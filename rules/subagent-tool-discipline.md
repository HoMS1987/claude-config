# Sub-Agent Tool-Disziplin

## REGEL - IMMER EINHALTEN

Sub-Agents (via Agent/Task Tool) MÜSSEN vorhandene Skills und Tools verwenden. **NIEMALS** ad-hoc Lösungen bauen, wenn ein passender Skill existiert.

## Pflichten des Orchestrators

Bevor ein Sub-Agent gestartet wird:

1. **Skills prüfen**: Gibt es einen Skill für die Aufgabe? → Im Prompt explizit benennen
2. **Tool-Hinweis geben**: Dem Sub-Agent im Prompt mitteilen, WELCHE Skills/Tools er verwenden soll
3. **Anti-Patterns benennen**: Explizit angeben, was der Sub-Agent NICHT tun soll

## Beispiel: Korrekte Delegation

```
# ❌ FALSCH (Sub-Agent kennt Skills und Tools nicht)
"Erstelle einen Pull Request für den aktuellen Branch"

# ✅ RICHTIG (Skills und Tools explizit benannt)
"Erstelle den Pull Request mit `gh pr create` gegen `dev`.
 Titel und Beschreibung nach den PR-Regeln (gesamter Branch-Diff).
 NIEMALS die GitHub-API über ein ad-hoc geschriebenes Skript ansprechen!"
```

## Warum?

| Problem | Konsequenz |
|---------|------------|
| Sub-Agent kennt Skills nicht | Baut ad-hoc Lösung (fehleranfällig) |
| Kein Tool-Hinweis im Prompt | Sub-Agent wählt einfachsten Weg (oft falsch) |
| Bestehende Features ignoriert | Doppelte Arbeit, inkonsistente Ergebnisse |
