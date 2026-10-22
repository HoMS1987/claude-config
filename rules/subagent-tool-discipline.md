# Sub-Agent Tool-Disziplin

Sub-Agents (Agent/Task-Tool) kennen die vorhandenen Skills und Tools nicht von selbst und wählen sonst
den einfachsten, oft falschen Weg. Bevor ein Sub-Agent startet, nennt der Prompt deshalb:

1. **Skills**, die für die Aufgabe existieren
2. **Tools und Befehle**, die er verwenden soll
3. **Anti-Patterns**, die er vermeiden soll

```
# ❌ FALSCH
"Erstelle einen Pull Request für den aktuellen Branch"

# ✅ RICHTIG
"Erstelle den Pull Request mit `gh pr create` gegen `dev`.
 Titel und Beschreibung nach den PR-Regeln (gesamter Branch-Diff).
 NIEMALS die GitHub-API über ein ad-hoc geschriebenes Skript ansprechen!"
```
