# Git-Identität

Commits erscheinen nie unter meinem Klarnamen oder einer privaten E-Mail-Adresse.
Die globale Git-Konfiguration kann beides enthalten, deshalb gilt die Identität
pro Repository und wird nie stillschweigend aus der globalen Konfiguration übernommen.

## Vor jedem Commit

Prüfen, woher Name und Adresse kommen:

```
git config --show-origin user.name
git config --show-origin user.email
```

Stammt einer der Werte aus der globalen Konfiguration oder fehlt er, die passende
Identität ermitteln und lokal setzen (`git config user.name …`, ohne `--global`):

1. Die Identität meiner bisherigen Commits in diesem Repository (`git log`).
2. Bei GitHub-Repositories der GitHub-Benutzername und die noreply-Adresse
   (`<ID>+<Benutzername>@users.noreply.github.com`, z. B. über `gh api user`).
3. Ist beides nicht eindeutig: nachfragen, nicht raten.

Das Setzen kurz melden. Die globale Konfiguration nicht ändern.

## Vor jedem Push

Autor und Committer der Commits prüfen, die neu hinausgehen:

```
git log --format='%h %an <%ae> | %cn <%ce>' @{u}..
```

Steht dort der Klarname aus der globalen Konfiguration oder eine private Adresse,
nicht pushen, sondern nachfragen.
