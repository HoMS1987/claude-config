# Claude Code Statusleiste: Ordner | Git-Branch | Kontextfenster | Modell
$ErrorActionPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [Text.Encoding]::UTF8

$stdin = [IO.StreamReader]::new([Console]::OpenStandardInput(), [Text.UTF8Encoding]::new($false))
$j = $stdin.ReadToEnd() | ConvertFrom-Json
$e = [char]27
$dim = "$e[2m"; $reset = "$e[0m"
$sep = " $dim|$reset "

# Ordner (~ fuer Home, lange Pfade auf die letzten zwei Ebenen kuerzen)
$dir = $j.workspace.current_dir ?? $j.cwd ?? (Get-Location).Path
$shown = $dir
if ($shown.StartsWith($HOME, [StringComparison]::OrdinalIgnoreCase)) { $shown = '~' + $shown.Substring($HOME.Length) }
if ($shown.Length -gt 40) {
    $parts = $shown -split '[\\/]'
    $shown = '…\' + ($parts[-2..-1] -join '\')
}
$out = "$e[36m$shown$reset"

# Git-Branch (nur innerhalb eines Repositories)
$status = git -C $dir status --porcelain=v2 --branch 2>$null
if ($status) {
    $branch = $null; $oid = $null; $ahead = 0; $behind = 0; $dirty = $false
    foreach ($line in $status) {
        if ($line -match '^# branch\.head (.+)$') { $branch = $Matches[1] }
        elseif ($line -match '^# branch\.oid (.+)$') { $oid = $Matches[1] }
        elseif ($line -match '^# branch\.ab \+(\d+) -(\d+)$') { $ahead = [int]$Matches[1]; $behind = [int]$Matches[2] }
        elseif ($line -notmatch '^#') { $dirty = $true }
    }
    if ($branch -eq '(detached)' -and $oid.Length -ge 7) { $branch = $oid.Substring(0, 7) }
    $git = "⎇ $branch"
    if ($dirty) { $git += '*' }
    if ($ahead) { $git += " ↑$ahead" }
    if ($behind) { $git += " ↓$behind" }
    $out += "$sep$e[35m$git$reset"
}

# Kontextfenster
$pct = [int][math]::Round([double]($j.context_window.used_percentage ?? 0))
$pct = [math]::Min(100, [math]::Max(0, $pct))
$color = if ($pct -ge 80) { 31 } elseif ($pct -ge 50) { 33 } else { 32 }
$filled = [int][math]::Floor($pct / 10)
$bar = ('█' * $filled) + ('░' * (10 - $filled))
$out += "$sep$e[${color}m$bar $pct%$reset"

# Modell
$model = $j.model.display_name ?? $j.model.id
if ($model) { $out += "$sep$e[33m$model$reset" }

# Nutzungslimits (nur wenn Claude Code sie mitliefert, z.B. im Abo)
$limits = @()
foreach ($l in @(@('5h', $j.rate_limits.five_hour), @('7d', $j.rate_limits.seven_day))) {
    $used = $l[1].used_percentage
    if ($null -ne $used) {
        $u = [int][math]::Round([double]$used)
        $c = if ($u -ge 80) { 31 } elseif ($u -ge 50) { 33 } else { 32 }
        $item = "$dim$($l[0])$reset $e[${c}m$u%$reset"
        # Reset-Uhrzeit (lokal) nur fuer das 5h-Fenster
        if ($l[0] -eq '5h' -and $l[1].resets_at) {
            $at = [DateTimeOffset]::FromUnixTimeSeconds([long]$l[1].resets_at).LocalDateTime
            $item += " $dim↻ $($at.ToString('HH:mm'))$reset"
        }
        $limits += $item
    }
}
if ($limits) { $out += $sep + ($limits -join ' ') }

[Console]::Out.Write($out)
