#requires -Version 5.1
if (-not (. (Join-Path $PSScriptRoot 'Common.ps1') -CallerPath $PSCommandPath -SkipAdminCheck)) { return }

$configPath = Join-Path $PSScriptRoot 'config.ps1'
if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    throw '找不到 config.ps1，請先複製 config.example.ps1 為 config.ps1 並填入個人資訊。'
}
. $configPath
foreach ($name in @('GitName', 'GitEmail')) {
    if ([string]::IsNullOrWhiteSpace($Config[$name])) {
        throw "config.ps1 的 $name 不可為空白。"
    }
}
foreach ($command in @('pwsh', 'dotnet', 'git', 'npx', 'npm', 'oh-my-posh')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "找不到 $command，請先完成第 0–4 階段，再重新開啟一般權限的 PowerShell。"
    }
}
$powerToysPath = Get-RefillingPowerToysPath

. (Join-Path $PSScriptRoot 'TerminalSettings.ps1')
$profilePath = Join-Path $env:USERPROFILE 'Microsoft.PowerShell_profile.ps1'
# 固定使用穩定版的套件資料夾，避免誤改 Preview 的設定。
$terminalPackage = 'Microsoft.WindowsTerminal_8wekyb3d8bbwe'
$settingsPath = Join-Path $env:LOCALAPPDATA "Packages/$terminalPackage/LocalState/settings.json"

Write-Host '安裝工具與設定個人環境'
Add-RefillingNuGetSource
Invoke-ExternalCommand -FilePath dotnet -ArgumentList @('tool', 'install', '--global', 'dotnet-ef')

Invoke-ExternalCommand -FilePath npx -ArgumentList @('-y', '@willh/git-setup', '--name', $Config.GitName, '--email', $Config.GitEmail)
Invoke-ExternalCommand -FilePath git -ArgumentList @('config', '--global', '--add', 'safe.directory', '*')
Invoke-ExternalCommand -FilePath git -ArgumentList @('config', '--global', 'worktree.useRelativePaths', 'true')
Invoke-ExternalCommand -FilePath git -ArgumentList @('config', '--global', 'core.longpaths', 'true')
Invoke-ExternalCommand -FilePath git -ArgumentList @('config', '--global', 'fetch.prune', 'true')

# 保留已有排除規則，只補上本專案需要的項目。
$globalGitignorePath = Join-Path $env:USERPROFILE '.gitignore_global'
$gitignoreContent = if (Test-Path -LiteralPath $globalGitignorePath) {
    Get-Content -LiteralPath $globalGitignorePath
} else {
    @()
}
if ($gitignoreContent -notcontains '*.lscache') {
    Add-Content -LiteralPath $globalGitignorePath -Value "`n*.lscache"
}
Invoke-ExternalCommand -FilePath git -ArgumentList @('config', '--global', 'core.excludesfile', $globalGitignorePath)

# 模組供日常 PowerShell 7 使用，避免從 5.1 安裝到 WindowsPowerShell 的模組目錄。
$moduleInstallCommand = @'
$ErrorActionPreference = 'Stop'
Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force
'@
$encodedModuleInstallCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($moduleInstallCommand))
Invoke-ExternalCommand -FilePath pwsh -ArgumentList @('-NoProfile', '-NonInteractive', '-EncodedCommand', $encodedModuleInstallCommand)

if (Test-Path -LiteralPath $profilePath) {
    $backupPath = "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss_fff')"
    Copy-Item -LiteralPath $profilePath -Destination $backupPath
    Write-Host "已備份 Profile 至 $backupPath" -ForegroundColor Yellow
}
$profileContent = @'
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\gmay.omp.json" | Invoke-Expression
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
Import-Module Terminal-Icons

function de {
    <# .SYNOPSIS 進入指定 Docker 容器的互動式 Shell。 #>
    param([string]$container, [string]$shell = "zsh")
    docker exec -it $container $shell
}


function d {
    <# .SYNOPSIS 切換至目前使用者的桌面。 #>
    Set-Location -LiteralPath ([Environment]::GetFolderPath('Desktop'))
}

function Invoke-Copse {
    <# .SYNOPSIS 執行 worktree 工具並切換至工具回報的目錄。 #>
    $output = & "copse" @args
    $output | Write-Output
    $cdLine = $output | Select-String '^COPSE_CD:(.+)$' | Select-Object -Last 1
    if ($cdLine) {
        Set-Location -LiteralPath $cdLine.Matches.Groups[1].Value
    }
}
Set-Alias -Name wt -Value Invoke-Copse

function c
{
    <# .SYNOPSIS 以既有個人偏好啟動 Copilot。 #>
    copilot --yolo
}

function a
{
    <# .SYNOPSIS 以既有個人偏好啟動 Antigravity。 #>
    agy --dangerously-skip-permissions
}

function cc
{
    <# .SYNOPSIS 以既有個人偏好啟動 Claude Code。 #>
    claude --allow-dangerously-skip-permissions --dangerously-skip-permissions
}

function co
{
    <# .SYNOPSIS 以既有個人偏好啟動 Codex。 #>
    codex --dangerously-bypass-approvals-and-sandbox --dangerously-bypass-hook-trust
}
'@
[System.IO.File]::WriteAllText($profilePath, $profileContent, [System.Text.UTF8Encoding]::new($true))

if (Get-Command cargo -ErrorAction SilentlyContinue) {
    Invoke-ExternalCommand -FilePath cargo -ArgumentList @('install', 'git_worktree_copse')
} else {
    Write-Warning 'Cargo 未安裝，跳過 git_worktree_copse 安裝。'
}
Invoke-ExternalCommand -FilePath npm -ArgumentList @('install', '-g', 'yarn')

# Profile 與工具準備完成後，才建立會使用它們的登入啟動與 Terminal 設定。
$startupPath = [Environment]::GetFolderPath('Startup')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'AutoHotKey/autohotkey.ahk') -Destination (Join-Path $startupPath 'autohotkey.ahk')
$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut((Join-Path $startupPath 'PowerToys.lnk'))
$shortcut.TargetPath = $powerToysPath
$shortcut.Save()
Set-RefillingTerminalSettings -SettingsPath $settingsPath -ProfilePath $profilePath
Write-Host '個人環境與 Windows Terminal 設定已完成。請重新開啟 Terminal 以載入設定。'
Pause
