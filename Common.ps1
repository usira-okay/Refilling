#requires -Version 5.1
<#
.SYNOPSIS
初始化佈建腳本的工作目錄、錯誤政策及權限；提權另開程序後回傳 false。
#>
param(
    [Parameter(Mandatory = $true)] [string] $CallerPath,
    [switch] $SkipAdminCheck
)

$ErrorActionPreference = 'Stop'
# Windows PowerShell 5.1 的網路要求須可使用套件來源要求的 TLS 1.2。
if ($PSVersionTable.PSVersion.Major -lt 6) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}
. (Join-Path $PSScriptRoot 'ScriptHelpers.ps1')
Set-Location -LiteralPath (Split-Path -LiteralPath $CallerPath)

if (-not $SkipAdminCheck) {
    if (-not (. (Join-Path $PSScriptRoot 'Test-Admin.ps1') -p $CallerPath)) { return $false }
}
return $true
