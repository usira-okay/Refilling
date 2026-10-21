#requires -Version 7.0
if (-not (. (Join-Path $PSScriptRoot 'Common.ps1') -CallerPath $PSCommandPath -SkipAdminCheck)) { return }

# 檢查 NVM 是否已安裝
if (-not (Get-Command nvm -ErrorAction SilentlyContinue)) {
    throw 'NVM 未安裝，請先執行第 2 階段安裝 NVM，再重新開啟 PowerShell 7。'
}

Invoke-ExternalCommand -FilePath nvm -ArgumentList @('install', 'latest')

Invoke-ExternalCommand -FilePath nvm -ArgumentList @('use', 'latest')

Pause
