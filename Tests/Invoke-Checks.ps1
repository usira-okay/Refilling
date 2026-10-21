#Requires -Version 7.2
<#
.SYNOPSIS
依序執行語法解析、靜態分析與單元測試，不執行佈建入口。
.PARAMETER TestPath
要執行的 Pester 測試路徑；預設執行 Tests 內所有測試。
#>
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string[]]$TestPath = @($PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$sourceNames = & git -c core.quotepath=false -C $repositoryRoot ls-files --cached --others --exclude-standard
if ($LASTEXITCODE -ne 0) {
    throw '無法列出專案檔案，請確認 Git 與工作目錄。'
}
$sourcePaths = @($sourceNames | Where-Object {
    [System.IO.Path]::GetExtension($_) -in @('.ps1', '.psm1', '.psd1')
} | ForEach-Object { Join-Path $repositoryRoot $_ })

foreach ($sourcePath in $sourcePaths) {
    $tokens = $null
    $parseErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($sourcePath, [ref]$tokens, [ref]$parseErrors)
    if ($parseErrors.Count -gt 0) {
        throw "PowerShell 語法解析失敗：$sourcePath`n$($parseErrors | Out-String)"
    }
}
Write-Host "PowerShell 語法解析通過：$($sourcePaths.Count) 個檔案。"

Import-Module PSScriptAnalyzer -MinimumVersion 1.24.0
$diagnostics = @($sourcePaths | ForEach-Object {
    Invoke-ScriptAnalyzer -Path $_ -Severity Error
})
if ($diagnostics.Count -gt 0) {
    throw "PSScriptAnalyzer 發現錯誤：`n$($diagnostics | Format-Table ScriptName, Line, RuleName, Message -Wrap | Out-String)"
}
Write-Host 'PSScriptAnalyzer Error 級規則通過。'

if ($IsWindows) {
    if ([string]::IsNullOrWhiteSpace($env:REFILLING_AUTOHOTKEY_EXE) -or
        -not (Test-Path -LiteralPath $env:REFILLING_AUTOHOTKEY_EXE -PathType Leaf)) {
        throw '請將 REFILLING_AUTOHOTKEY_EXE 設為 AutoHotkey v2 執行檔路徑，再執行 Windows 驗證。'
    }
    & $env:REFILLING_AUTOHOTKEY_EXE /Validate /ErrorStdOut=UTF-8 (Join-Path $repositoryRoot 'AutoHotKey/autohotkey.ahk') | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "AutoHotkey 語法驗證失敗，結束碼：$LASTEXITCODE。"
    }
    Write-Host 'AutoHotkey v2 語法驗證通過。'
} else {
    Write-Host 'AutoHotkey 語法驗證需要 Windows，本次略過。'
}

Import-Module Pester -MinimumVersion 5.7.1 -MaximumVersion 5.999.999
$testResult = Invoke-Pester -Path $TestPath -Output Detailed -PassThru
if ($testResult.TotalCount -eq 0) {
    throw '沒有找到可執行的測試。'
}
if ($testResult.Result -ne 'Passed') {
    throw "Pester 驗證失敗：$($testResult.FailedCount) 個測試失敗、$($testResult.FailedContainersCount) 個測試容器失敗。"
}
