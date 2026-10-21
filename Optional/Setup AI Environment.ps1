#requires -Version 5.1
$projectRoot = Split-Path -LiteralPath $PSScriptRoot
if (-not (. (Join-Path $projectRoot 'Common.ps1') -CallerPath $PSCommandPath -SkipAdminCheck)) { return }

$instructionSource = Join-Path $projectRoot 'AGENTS.md'
if (-not (Test-Path -LiteralPath $instructionSource -PathType Leaf)) {
    throw "找不到專案的 AGENTS.md：$instructionSource"
}
foreach ($command in @('npx', 'winget')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "找不到 $command，請先完成第 0–4 階段，重新開啟終端機後再執行。"
    }
}
# 遠端安裝器固定使用第 0 階段安裝的 pwsh，避免受到入口 PowerShell 版本影響。
$powerShellCommand = Get-Command -Name pwsh -CommandType Application -ErrorAction SilentlyContinue
if (-not $powerShellCommand) {
    throw '找不到 pwsh，請先完成第 0 階段安裝 PowerShell 7，並重新開啟終端機後再執行。'
}
$powerShellExecutable = $powerShellCommand.Source

Write-Host '設定 AI 環境'

# AI CLI 安裝清單：Command 為安裝後的執行檔名稱，已存在就跳過
$cliInstallers = @(
    @{ Name = 'Claude Code'; Command = 'claude'; PackageId = 'Anthropic.ClaudeCode' }
    @{ Name = 'Codex'; Command = 'codex'; InstallerUri = 'https://chatgpt.com/codex/install.ps1' }
    @{ Name = 'GitHub Copilot'; Command = 'copilot'; PackageId = 'GitHub.Copilot' }
    @{ Name = 'Antigravity'; Command = 'agy'; InstallerUri = 'https://antigravity.google/cli/install.ps1' }
)

# 要安裝的 skills 來源：Skills 為 '*' 代表該 repo 的全部 skills
$skillSources = @(
    @{ Repo = 'github/awesome-copilot'; Skills = @('copilot-sdk') }
    @{ Repo = 'dotnet/skills'; Skills = @('dotnet-webapi') }
    @{ Repo = 'DietrichGebert/ponytail'; Skills = @('*') }
    @{ Repo = 'mattpocock/skills'; Skills = @('grilling') }
    @{ Repo = 'usira-okay/skills'; Skills = @('*') }
)
$skillAgents = @('claude-code', 'codex', 'github-copilot')

# Antigravity 不讀 ~/.agents/skills，需另外複製一份到它的全域 skills 資料夾
$agentsSkillsPath = Join-Path $env:USERPROFILE '.agents/skills'
$antigravitySkillsPath = Join-Path $env:USERPROFILE '.gemini/config/skills'

# 各 AI CLI 的全域指令檔，內容皆來自專案根目錄的 AGENTS.md
$instructionTargets = @(
    (Join-Path $env:USERPROFILE '.copilot/copilot-instructions.md')
    (Join-Path $env:USERPROFILE '.claude/CLAUDE.md')
    (Join-Path $env:USERPROFILE '.codex/AGENTS.md')
    (Join-Path $env:USERPROFILE '.gemini/GEMINI.md')
)

Write-Host '安裝 AI CLI'

foreach ($cli in $cliInstallers) {
    if (Get-Command $cli.Command -ErrorAction SilentlyContinue) {
        Write-Host "$($cli.Name) 已安裝，跳過安裝步驟" -ForegroundColor Yellow
    } else {
        Write-Host "安裝 $($cli.Name)"
        if ($cli.ContainsKey('PackageId')) {
            Invoke-ExternalCommand -FilePath winget -ArgumentList @(
                'install', '--id', $cli.PackageId, '--exact', '--source', 'winget',
                '--accept-package-agreements', '--accept-source-agreements'
            )
        } else {
            $installerPath = Join-Path ([System.IO.Path]::GetTempPath()) "refilling-$($cli.Command)-$([guid]::NewGuid().ToString('N')).ps1"
            try {
                Invoke-WebRequest -Uri $cli.InstallerUri -OutFile $installerPath -UseBasicParsing
                Invoke-ExternalCommand -FilePath $powerShellExecutable -ArgumentList @('-NoProfile', '-File', $installerPath)
            } finally {
                if (Test-Path -LiteralPath $installerPath) {
                    Remove-Item -LiteralPath $installerPath -Force
                }
            }
            if ($cli.Command -eq 'agy') {
                # 官方安裝器可忽略環境設定警告；直接驗證程式，避免依賴父視窗尚未更新的 PATH。
                $agyPath = Join-Path $env:LOCALAPPDATA 'agy/bin/agy.exe'
                if (-not (Test-Path -LiteralPath $agyPath -PathType Leaf)) {
                    throw "Antigravity 安裝後找不到執行檔：$agyPath"
                }
                Invoke-ExternalCommand -FilePath $agyPath -ArgumentList @('--version')
            }
        }
    }
}

Write-Host '安裝 AI Skills'

# --copy 讓各 agent 取得獨立複本，避免 Windows 非管理員 / 未開啟開發人員模式時無法建立 symlink
$agentArgs = $skillAgents | ForEach-Object { '-a', $_ }
foreach ($source in $skillSources) {
    $skillArgs = $source.Skills | ForEach-Object { '--skill', $_ }
    $arguments = @('-y', 'skills', 'add', $source.Repo) + $skillArgs + $agentArgs + @('-g', '-y', '--copy')
    Invoke-ExternalCommand -FilePath npx -ArgumentList $arguments
}

Write-Host '複製 Skills 至 Antigravity'

[System.IO.Directory]::CreateDirectory($antigravitySkillsPath) | Out-Null
Get-ChildItem -LiteralPath $agentsSkillsPath -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $antigravitySkillsPath -Recurse -Force
}

Write-Host '同步 AGENTS.md'

foreach ($target in $instructionTargets) {
    [System.IO.Directory]::CreateDirectory((Split-Path -LiteralPath $target)) | Out-Null
    Copy-Item -LiteralPath $instructionSource -Destination $target -Force
    Write-Host "已同步 $target"
}

Write-Host '完成，請重新開啟終端機讓新安裝的 CLI 生效' -ForegroundColor Green

Pause
