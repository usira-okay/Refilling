#requires -Version 5.1
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ScriptHelpers.ps1')

# 先確認本專案支援的系統，避免在不相容的電腦留下部分設定。
$minimumWindows11Build = 22000
$windowsProSku = 48
$workstationProductType = 1
$x64ProcessorArchitecture = 9
$operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
$processors = @(Get-CimInstance -ClassName Win32_Processor)
if ([int]$operatingSystem.BuildNumber -lt $minimumWindows11Build -or
    $operatingSystem.OperatingSystemSKU -ne $windowsProSku -or
    $operatingSystem.ProductType -ne $workstationProductType -or
    $processors.Count -eq 0 -or
    @($processors | Where-Object { $_.Architecture -ne $x64ProcessorArchitecture }).Count -gt 0) {
    throw '本專案僅支援 Windows 11 Pro x64 乾淨新機，尚未變更執行原則或安裝程式。'
}

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
