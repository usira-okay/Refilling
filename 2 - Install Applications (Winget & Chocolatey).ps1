Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Install Applications by Winget'
$ErrorActionPreference = 'Stop'

# PowerShell 5.1 預設不啟用 TLS 1.2，許多 HTTPS 端點需要 TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# 檢查 Winget 是否已安裝
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host 'Winget 已安裝，跳過安裝步驟' -ForegroundColor Yellow
} else {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile('https://aka.ms/getwinget', "$env:TEMP\winget.msixbundle")
    $webClient.DownloadFile('https://aka.ms/windowsappsdk/1.8/latest/windowsappruntimeinstall-x64.exe', "$env:TEMP\WinAppRuntime.exe")
    Start-Process -FilePath "$env:TEMP\WinAppRuntime.exe" -ArgumentList '--quiet' -Wait
    Add-AppxPackage -Path "$env:TEMP\winget.msixbundle"
}

$toolsJsonPath = '.\Winget Package\Tools.json'
if (-not (Test-Path $toolsJsonPath)) {
    Write-Error "找不到 $toolsJsonPath"
    exit 1
}

winget import -i '.\Winget Package\Tools.json' --accept-package-agreements --accept-source-agreements


Write-Host 'Visual Studio'

$command = "--allWorkloads --passive --installWhileDownloading --locale en-US --wait --norestart"

winget install --id Microsoft.VisualStudio.Community --override $command --accept-package-agreements --accept-source-agreements


Pause
