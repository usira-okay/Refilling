if (-not (. ..\Common.ps1 -CallerPath $PSCommandPath -SkipAdminCheck)) { return }

Write-Host 'Setup AI Environment'

# AI CLI 安裝清單：Command 為安裝後的執行檔名稱，已存在就跳過
$cliInstallers = @(
    @{ Name = 'Claude Code'; Command = 'claude'; Install = { Invoke-RestMethod -Uri https://claude.ai/install.ps1 | Invoke-Expression } }
    @{ Name = 'Codex'; Command = 'codex'; Install = { Invoke-RestMethod -Uri https://chatgpt.com/codex/install.ps1 | Invoke-Expression } }
    @{ Name = 'GitHub Copilot'; Command = 'copilot'; Install = { winget install --id GitHub.Copilot --accept-package-agreements --accept-source-agreements } }
    @{ Name = 'Antigravity'; Command = 'agy'; Install = { Invoke-RestMethod -Uri https://antigravity.google/cli/install.ps1 | Invoke-Expression } }
)

# 要安裝的 skills 來源：Skills 為 '*' 代表該 repo 的全部 skills
$skillSources = @(
    @{ Repo = 'github/awesome-copilot'; Skills = @('copilot-sdk') }
    @{ Repo = 'dotnet/skills'; Skills = @('dotnet-webapi') }
    @{ Repo = 'DietrichGebert/ponytail'; Skills = @('*') }
    @{ Repo = 'mattpocock/skills'; Skills = @('grill-me', 'grilling') }
    @{ Repo = 'usira-okay/skills'; Skills = @('*') }
)
$skillAgents = @('claude-code', 'codex', 'github-copilot')

# Antigravity 不讀 ~/.agents/skills，需另外複製一份到它的全域 skills 資料夾
$agentsSkillsPath = "$env:USERPROFILE\.agents\skills"
$antigravitySkillsPath = "$env:USERPROFILE\.gemini\config\skills"

# 各 AI CLI 的全域指令檔，內容皆來自專案根目錄的 AGENTS.md
$instructionTargets = @(
    "$env:USERPROFILE\.copilot\copilot-instructions.md"
    "$env:USERPROFILE\.claude\CLAUDE.md"
    "$env:USERPROFILE\.codex\AGENTS.md"
    "$env:USERPROFILE\.gemini\GEMINI.md"
)

Write-Host 'Install AI CLI'

foreach ($cli in $cliInstallers) {
    if (Get-Command $cli.Command -ErrorAction SilentlyContinue) {
        Write-Host "$($cli.Name) 已安裝，跳過安裝步驟" -ForegroundColor Yellow
    } else {
        Write-Host "Install $($cli.Name)"
        & $cli.Install
    }
}

Write-Host 'Install AI Skills'

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    Write-Error 'npx 未安裝，請先執行腳本 4 安裝 Node.js'
    exit 1
}

# --copy 讓各 agent 取得獨立複本，避免 Windows 非管理員 / 未開啟開發人員模式時無法建立 symlink
$agentArgs = $skillAgents | ForEach-Object { '-a', $_ }
foreach ($source in $skillSources) {
    $skillArgs = $source.Skills | ForEach-Object { '--skill', $_ }
    npx -y skills add $source.Repo @skillArgs @agentArgs -g -y --copy
}

Write-Host 'Copy Skills to Antigravity'

New-Item -Path $antigravitySkillsPath -ItemType Directory -Force | Out-Null
Copy-Item -Path "$agentsSkillsPath\*" -Destination $antigravitySkillsPath -Recurse -Force

Write-Host 'Sync AGENTS.md'

foreach ($target in $instructionTargets) {
    New-Item -Path (Split-Path $target) -ItemType Directory -Force | Out-Null
    Copy-Item -Path ..\AGENTS.md -Destination $target -Force
    Write-Host "已同步 $target"
}

Write-Host '完成，請重新開啟終端機讓新安裝的 CLI 生效' -ForegroundColor Green

Pause
