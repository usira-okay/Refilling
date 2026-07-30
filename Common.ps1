# 共用的腳本啟動流程，供各腳本以 . .\Common.ps1 -CallerPath $PSCommandPath 呼叫
# 職責：切換工作目錄、檢查管理員權限（非管理員會自動提權重啟）、啟用 TLS 1.2
#
# 回傳值：
#   $true  — 已具備管理員權限，呼叫端可繼續往下執行
#   $false — 已嘗試提權重啟，呼叫端應立即 return，避免以非管理員權限繼續執行

param(
    [Parameter(Mandatory = $true)]
    [string]$CallerPath,

    # Scoop / NVM 等僅安裝於使用者範圍的腳本可加此旗標跳過管理員權限檢查
    [switch]$SkipAdminCheck
)

Set-Location ([System.IO.Path]::GetDirectoryName($CallerPath))

if (-not $SkipAdminCheck) {
    if (-not (. "$PSScriptRoot\Test-Admin.ps1" -p $CallerPath)) { return $false }
}

$ErrorActionPreference = 'Stop'

# PowerShell 5.1 預設不啟用 TLS 1.2，許多 HTTPS 端點需要 TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

return $true
