Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))
. .\config.ps1

Write-Host 'Install Applications by Scoop'
$ErrorActionPreference = 'Stop'

# PowerShell 5.1 預設不啟用 TLS 1.2，許多 HTTPS 端點需要 TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# 檢查 Scoop 是否已安裝
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host 'Scoop 已安裝，跳過安裝步驟' -ForegroundColor Yellow
} else {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# 設定 Scoop 快取資料夾指向沙箱掛載的本機資料夾
scoop config cache_path $Config.ScoopCachePath

# 安裝 Maple Mono NF CN 字型
scoop bucket add nerd-fonts
scoop install nerd-fonts/Maple-Mono-NF-CN
scoop install oh-my-posh

Pause
