#requires -Version 7.0
<# .SYNOPSIS 將目前使用者的桌面指向既有資料夾，並重新啟動 Explorer 套用設定。 #>
$repositoryRoot = Split-Path $PSScriptRoot -Parent
if (-not (. (Join-Path $repositoryRoot 'Common.ps1') -CallerPath $PSCommandPath -SkipAdminCheck)) { return }

$configPath = Join-Path $repositoryRoot 'config.ps1'
if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    throw '找不到 config.ps1，請先複製 config.example.ps1 為 config.ps1 並填入個人資訊。'
}
. $configPath

$newPath = $Config.DesktopPath
if ([string]::IsNullOrWhiteSpace($newPath) -or
    -not (Test-Path -LiteralPath $newPath -PathType Container)) {
    throw "DesktopPath 必須是存在的資料夾：$newPath"
}
$desktopDirectory = Get-Item -LiteralPath $newPath
if ($desktopDirectory -isnot [System.IO.DirectoryInfo]) {
    throw "DesktopPath 必須是檔案系統資料夾：$newPath"
}
$newPath = $desktopDirectory.FullName

$registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
Set-ItemProperty -Path $registryPath -Name Desktop -Value $newPath
Stop-Process -Name explorer -Force
Start-Process explorer

Write-Host "桌面路徑已更新為 '$newPath'。" -ForegroundColor Green
Pause
