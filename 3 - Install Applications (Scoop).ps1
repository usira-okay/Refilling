if (-not (. .\Common.ps1 -CallerPath $PSCommandPath -SkipAdminCheck)) { return }

if (-not (Test-Path .\config.ps1)) {
    Write-Error '找不到 config.ps1，請先複製 config.example.ps1 為 config.ps1 並填入個人資訊'
    exit 1
}
. .\config.ps1

Write-Host 'Install Applications by Scoop'

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
