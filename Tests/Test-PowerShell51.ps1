#requires -Version 5.1
<#
.SYNOPSIS
檢查引導腳本的 UTF-8 BOM 與 PowerShell 5.1 語法，不執行佈建。
.DESCRIPTION
以有 BOM 的檔案保留中文，避免 CI 產生的暫存腳本使用系統編碼讀取中文。
#>
$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
foreach ($path in @('0 - Set ExecutionPolicy - 手動執行.ps1', 'ScriptHelpers.ps1')) {
    $fullPath = Join-Path $repositoryRoot $path
    $bytes = [System.IO.File]::ReadAllBytes($fullPath)
    if ([System.BitConverter]::ToString($bytes, 0, 3) -ne 'EF-BB-BF') {
        throw "$path 必須以 UTF-8 BOM 儲存，確保 Windows PowerShell 5.1 正確讀取中文。"
    }
    $tokens = $null
    $parseErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($fullPath, [ref]$tokens, [ref]$parseErrors)
    if ($parseErrors.Count -gt 0) {
        throw "$path`n$($parseErrors | Out-String)"
    }
}
