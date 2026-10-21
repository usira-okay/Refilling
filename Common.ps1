#requires -Version 7.0
<#
.SYNOPSIS
初始化佈建腳本的工作目錄、錯誤政策及權限；提權另開程序後回傳 false。
#>
param(
    [Parameter(Mandatory = $true)] [string] $CallerPath,
    [switch] $SkipAdminCheck
)

$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'Refilling 僅支援 Windows 11 Pro x64。' }
. (Join-Path $PSScriptRoot 'ScriptHelpers.ps1')
Set-Location -LiteralPath (Split-Path -LiteralPath $CallerPath)

if (-not $SkipAdminCheck) {
    if (-not (. (Join-Path $PSScriptRoot 'Test-Admin.ps1') -p $CallerPath)) { return $false }
}
return $true
