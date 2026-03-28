Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Install Applications by Winget'

# PowerShell 5.1 預設不啟用 TLS 1.2，許多 HTTPS 端點需要 TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile('https://aka.ms/getwinget', "$env:TEMP\winget.msixbundle")
$webClient.DownloadFile('https://aka.ms/windowsappsdk/1.8/latest/windowsappruntimeinstall-x64.exe', "$env:TEMP\WinAppRuntime.exe")
Start-Process -FilePath "$env:TEMP\WinAppRuntime.exe" -ArgumentList '--quiet' -Wait
Add-AppxPackage -Path "$env:TEMP\winget.msixbundle"

winget import -i '.\Winget Package\Tools.json' --accept-package-agreements --accept-source-agreements


Write-Host 'Visual Studio'

$command = "--allWorkloads --passive --installWhileDownloading --locale en-US --wait --norestart"

winget install --id Microsoft.VisualStudio.Community --override $command --accept-package-agreements --accept-source-agreements
winget install Microsoft.VisualStudio.2022.BuildTools --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"


Write-Host 'Install Applications by Chocolatey'
# Install Applications by Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install ffmpeg `
    filezilla `
    gawk `
    grep -y 

choco install autohotkey --version=1.1.37.1 -y 
choco install line -y --ignore-checksums
    
Pause
