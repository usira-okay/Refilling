#requires -Version 7.0
$projectRoot = Split-Path -LiteralPath $PSScriptRoot
if (-not (. (Join-Path $projectRoot 'Common.ps1') -CallerPath $PSCommandPath)) { return }

Write-Host '隱藏關機與睡眠按鈕'

Invoke-ExternalCommand -FilePath reg -ArgumentList @(
    'add', 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Start\HideShutDown',
    '/t', 'REG_DWORD', '/v', 'value', '/d', '1', '/f'
)
Invoke-ExternalCommand -FilePath reg -ArgumentList @(
    'add', 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Start\HideSleep',
    '/t', 'REG_DWORD', '/v', 'value', '/d', '1', '/f'
)

Pause
