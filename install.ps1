#Requires -Version 7
# Installiert die Konfiguration aus diesem Repository nach ~/.claude.
# Bestehende, abweichende Dateien werden vorher als *.bak-<Zeitstempel> gesichert.
param(
    [string]$ClaudeDir = (Join-Path $HOME '.claude'),
    # Warnhinweis beim Start im Modus "bypass permissions" überspringen: ask = nachfragen
    [ValidateSet('ask', 'yes', 'no')]
    [string]$SkipDangerousModePrompt = 'ask'
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8

$repo = $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
New-Item -ItemType Directory -Force $ClaudeDir | Out-Null
$ClaudeDir = (Resolve-Path $ClaudeDir).Path

function Backup-File($path) {
    Copy-Item $path "$path.bak-$stamp"
    Write-Host "  Sicherung: $path.bak-$stamp"
}

# Dateien, die 1:1 kopiert werden
foreach ($name in 'CLAUDE.md', 'statusline.ps1') {
    $src = Join-Path $repo $name
    $dst = Join-Path $ClaudeDir $name
    if (Test-Path $dst) {
        if ((Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash) {
            Write-Host "= $name (unverändert)"
            continue
        }
        Backup-File $dst
    }
    Copy-Item $src $dst -Force
    Write-Host "+ $name"
}

# settings.json: Schlüssel aus dem Repository in die bestehende Datei einmischen.
# Werte aus dem Repository gewinnen, alle anderen vorhandenen Schlüssel bleiben erhalten.
$dst = Join-Path $ClaudeDir 'settings.json'
$wanted = (Get-Content (Join-Path $repo 'settings.json') -Raw).Replace('{{CLAUDE_DIR}}', $ClaudeDir.Replace('\', '/')) |
    ConvertFrom-Json -AsHashtable
$old = if (Test-Path $dst) { Get-Content $dst -Raw } else { '{}' }
$current = $old | ConvertFrom-Json -AsHashtable

foreach ($key in $wanted.Keys) {
    if ($wanted[$key] -is [System.Collections.IDictionary] -and $current[$key] -is [System.Collections.IDictionary]) {
        foreach ($sub in $wanted[$key].Keys) { $current[$key][$sub] = $wanted[$key][$sub] }
    } else {
        $current[$key] = $wanted[$key]
    }
}

# skipDangerousModePermissionPrompt ist eine bewusste Entscheidung und wird deshalb abgefragt.
# Ohne interaktive Konsole bleibt der vorhandene Wert unverändert.
$key = 'skipDangerousModePermissionPrompt'
$choice = $SkipDangerousModePrompt
if ($choice -eq 'ask') {
    if ([Console]::IsInputRedirected) {
        $choice = 'keep'
    } else {
        $default = if ($current[$key]) { 'j' } else { 'n' }
        Write-Host 'Der Modus "bypass permissions" führt alle Aktionen ohne Rückfrage aus.'
        $answer = Read-Host "Warnhinweis beim Start dieses Modus dauerhaft überspringen? (j/n) [$default]"
        if (-not $answer) { $answer = $default }
        $choice = if ($answer -match '^[jy]') { 'yes' } else { 'no' }
    }
}
if ($choice -eq 'yes') { $current[$key] = $true }
elseif ($choice -eq 'no') { $current.Remove($key) }

$new = $current | ConvertTo-Json -Depth 20
if ($new.Trim() -eq $old.Trim()) {
    Write-Host '= settings.json (unverändert)'
} else {
    if (Test-Path $dst) { Backup-File $dst }
    Set-Content $dst $new
    Write-Host '+ settings.json'
}

Write-Host "Fertig. Claude Code neu starten, damit alle Änderungen greifen."
