Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Install Applications by Winget'

Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.3.2691/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile .\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

winget import -i '.\Winget Package\Tools.json' --accept-package-agreements --accept-source-agreements

Write-Host 'Install Applications by Chocolatey'
# Install Applications by Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install sqlpackage `
    ffmpeg `
    ngrok `
    filezilla -y

Pause
