#requires -Version 7.0
if (-not (. (Join-Path $PSScriptRoot 'Common.ps1') -CallerPath $PSCommandPath -SkipAdminCheck)) { return }

if (Test-IsAdministrator) {
    throw 'Scoop 必須在一般權限的 PowerShell 7 執行，請關閉此管理員視窗後重試。'
}

$configPath = Join-Path $PSScriptRoot 'config.ps1'
if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    throw '找不到 config.ps1，請先複製 config.example.ps1 為 config.ps1 並填入個人資訊。'
}
. $configPath

Write-Host '透過 Scoop 安裝應用程式'

# 檢查 Scoop 是否已安裝
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host 'Scoop 已安裝，跳過安裝步驟' -ForegroundColor Yellow
} else {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        throw 'Scoop 安裝後仍找不到 scoop，請查看安裝輸出並重新開啟一般權限的 PowerShell 7。'
    }
}

# 設定 Scoop 快取資料夾指向沙箱掛載的本機資料夾
Invoke-ExternalCommand -FilePath scoop -ArgumentList @('config', 'cache_path', $Config.ScoopCachePath)

# 安裝 Maple Mono NF CN 字型
Invoke-ExternalCommand -FilePath scoop -ArgumentList @('bucket', 'add', 'nerd-fonts')
Invoke-ExternalCommand -FilePath scoop -ArgumentList @('install', 'nerd-fonts/Maple-Mono-NF-CN')
Invoke-ExternalCommand -FilePath scoop -ArgumentList @('install', 'oh-my-posh')

Pause
