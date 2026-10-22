#Requires -Version 7
# Tests for install.ps1. Runs the installer against temporary directories and exits with 1 on failure.
$ErrorActionPreference = 'Stop'

$installer = Join-Path $PSScriptRoot '..' 'install.ps1'
$failures = 0

function Invoke-Installer($claudeDir) {
    pwsh -NoProfile -File $installer -ClaudeDir $claudeDir -SkipDangerousModePrompt no | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "install.ps1 failed with exit code $LASTEXITCODE" }
}

function Test-Case($name, [scriptblock]$body) {
    $dir = Join-Path ([IO.Path]::GetTempPath()) "claude-config-test-$([guid]::NewGuid())"
    try {
        & $body $dir
        Write-Host "PASS $name"
    } catch {
        Write-Host "FAIL $name`n     $_"
        $script:failures++
    } finally {
        Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Test-Case 'A second run changes nothing' {
    param($dir)
    Invoke-Installer $dir
    Invoke-Installer $dir
    $backups = @(Get-ChildItem $dir -Recurse -Filter '*.bak-*')
    if ($backups) { throw "Unexpected backups: $($backups.Name -join ', ')" }
}

Test-Case 'settings.json rewritten by Claude Code with LF line endings counts as unchanged' {
    param($dir)
    Invoke-Installer $dir
    $settings = Join-Path $dir 'settings.json'
    # Claude Code itself writes settings.json with LF line endings.
    $lf = (Get-Content $settings -Raw) -replace "`r`n", "`n"
    [IO.File]::WriteAllText($settings, $lf)
    Invoke-Installer $dir
    $backups = @(Get-ChildItem $dir -Filter 'settings.json.bak-*')
    if ($backups) { throw "Unexpected backup: $($backups.Name -join ', ')" }
}

if ($failures) { exit 1 }
