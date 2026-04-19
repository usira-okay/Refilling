Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))
$ErrorActionPreference = 'Stop'

# 檢查 NVM 是否已安裝
if (-not (Get-Command nvm -ErrorAction SilentlyContinue)) {
    Write-Error 'NVM 未安裝，請先執行腳本 2 安裝 NVM'
    exit 1
}

nvm install latest

nvm use latest

Pause
