# Git Bash: Pfadumwandlung bei entfernten Pfaden abschalten

Git Bash (MSYS) schreibt Argumente, die wie POSIX-Pfade aussehen, in Windows-Pfade um:
aus `/tmp/x` wird `C:/Users/…/AppData/Local/Temp/x`. Bei Befehlen, deren Pfade **nicht auf
diesem Rechner** gelten, landet dadurch ein falscher Pfad im Container, Pod oder auf dem Server.
So ist schon ein Ordner `C:` in einem persistenten Webroot entstanden.

## Regel

Bei solchen Befehlen im Bash-Tool `MSYS_NO_PATHCONV=1` setzen oder PowerShell verwenden:

```bash
MSYS_NO_PATHCONV=1 kubectl exec -n app pod -- mkdir -p /tmp/x
```

Betroffen sind unter anderem `kubectl exec`/`cp`, `docker exec`/`run`/`cp` (auch `-v`),
`ssh` und `scp` mit entfernten Pfaden sowie `talosctl`.

Vor einem Schreibzugriff mit entferntem Pfad den Pfad zuerst harmlos prüfen,
z. B. mit `echo` im Pod.
