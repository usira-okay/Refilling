Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Install Applications by Winget'

Write-Information "Downloading WinGet and its dependencies..."
$location = Get-Location
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile('https://aka.ms/getwinget', "$location\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")
$webClient.DownloadFile('https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx', "$location\Microsoft.VCLibs.x64.14.00.Desktop.appx")
$webClient.DownloadFile('https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx', "$location\Microsoft.UI.Xaml.2.7.x64.appx")

Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.UI.Xaml.2.7.x64.appx
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

winget import -i '.\Winget Package\Tools.json' --accept-package-agreements --accept-source-agreements

Write-Host 'Install Applications by Chocolatey'
# Install Applications by Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install sqlpackage `
    ffmpeg `
    filezilla `
    gawk `
    grep -y 

choco install autohotkey --version=1.1.37.1 -y 
choco install line -y --ignore-checksums
    
Pause
