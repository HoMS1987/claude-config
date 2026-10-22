# Pull Requests

## Ziel-Branch

PRs gehen gegen `dev`, nicht gegen `main`/`master` — `main` ist nur für
fertige Releases.

**Vorgehen:** Vor dem Erstellen prüfen, ob ein `dev`-Branch auf dem Remote
existiert (`git ls-remote --heads origin dev`). Falls ja → Base `dev`.
Falls nicht → Default-Branch des Repositories.

## Sprache

Titel und Beschreibung von PRs werden **immer auf Englisch** verfasst, ebenso
Review-Kommentare in PRs. Die Prinzipien aus `adler-communication-style.md`
gelten sinngemäß auch auf Englisch. In fremden Repositories gilt deren Sprache
(siehe `third-party-repositories.md`).

## Titel und Beschreibung

Titel und Beschreibung fassen den **gesamten Branch-Diff** gegenüber dem
Base-Branch zusammen — nicht nur den zuletzt erstellten Commit.

**Vorgehen:** Vor `gh pr create` immer

```bash
git log <base>..HEAD --reverse --oneline
git diff <base>...HEAD --stat
```

ansehen und Titel/Beschreibung am vollständigen Umfang ausrichten.

Für den Text der Beschreibung gilt `adler-communication-style.md`.
