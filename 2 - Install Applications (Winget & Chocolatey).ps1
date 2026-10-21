#requires -Version 5.1
if (-not (. (Join-Path $PSScriptRoot 'Common.ps1') -CallerPath $PSCommandPath)) { return }

Write-Host '透過 WinGet 安裝應用程式'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw '找不到 WinGet，請先完成第 0 階段，再重新開啟 PowerShell。'
}

$toolsJsonPath = Join-Path $PSScriptRoot 'Winget Package/Tools.json'
if (-not (Test-Path -LiteralPath $toolsJsonPath -PathType Leaf)) {
    throw "找不到套件清單：$toolsJsonPath"
}

Invoke-ExternalCommand -FilePath winget -ArgumentList @(
    'import', '-i', $toolsJsonPath, '--accept-package-agreements', '--accept-source-agreements'
)

Write-Host 'Visual Studio Build Tools'

# Rust 的 MSVC 工具鏈需要連結器與 Windows SDK，推薦元件會一併安裝。
Invoke-ExternalCommand -FilePath winget -ArgumentList @(
    'install', '--id', 'Microsoft.VisualStudio.2022.BuildTools', '--exact', '--source', 'winget',
    '--override', '--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended',
    '--accept-package-agreements', '--accept-source-agreements'
)

Write-Host '透過 Chocolatey 安裝 FileZilla'
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host 'Chocolatey 已安裝，跳過安裝步驟' -ForegroundColor Yellow
} else {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri 'https://community.chocolatey.org/install.ps1' | Invoke-Expression
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        throw 'Chocolatey 安裝後仍找不到 choco，請查看安裝輸出並重新開啟 PowerShell。'
    }
}

# WinGet 套件庫不提供 FileZilla，僅保留此項使用 Chocolatey。
Invoke-ExternalCommand -FilePath choco -ArgumentList @('install', 'filezilla', '-y')

Pause
