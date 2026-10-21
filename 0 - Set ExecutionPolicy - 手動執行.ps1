#requires -Version 5.1
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ScriptHelpers.ps1')

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    # 新使用者首次登入時，App Installer 可能尚未完成註冊。
    Write-Host '正在註冊 App Installer；若失敗，請先從 Microsoft Store 安裝或更新 App Installer。'
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw '找不到 WinGet。請安裝或更新 App Installer，重新開啟 Windows PowerShell 後再執行本腳本：https://apps.microsoft.com/detail/9NBLGGH4NNS1'
    }
}

if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    Invoke-ExternalCommand -FilePath winget -ArgumentList @(
        'install', '--id', 'Microsoft.PowerShell', '--exact', '--source', 'winget',
        '--accept-package-agreements', '--accept-source-agreements'
    )
}

Write-Host '引導完成。請關閉此視窗，新開一般權限的 Windows PowerShell 5.1 或 PowerShell 7，再依序執行第 1 階段。'
