Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

Write-Host 'Install Applications by Scoop'

Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# 設定 Scoop 快取資料夾指向沙箱掛載的本機資料夾
scoop config cache_path "C:\ScoopCache"

# 安裝 Maple Mono NF CN 字型
scoop bucket add nerd-fonts
scoop install nerd-fonts/Maple-Mono-NF-CN
scoop install oh-my-posh

Pause
