# Add US and TW Keyboard
$UserLanguageList = New-WinUserLanguageList -Language "zh-TW"
$UserLanguageList.Add("en-US")
Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
Set-WinDefaultInputMethodOverride -InputTip "0409:00000409"

# Install Applications by Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install sqlpackage googlechrome line teamviewer telegram 7zip adobereader discord postman vscode nodejs git sourcetree visualstudio2019community visualstudio2019enterprise visualstudio2022community sql-server-management-studio potplayer microsoft-teams docker-desktop wsl2 openshot obs-studio zoom nuget.commandline stream-client office365business -y


# Refresh Chocolatey environment 
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   

Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

refreshenv

# Install develoment tools
npm i -g @angular/cli
code --install-extension "shan.code-settings-sync"
npm i -g nswag

# Add Nuget Offical Source
nuget source add -name nuget -source https://api.nuget.org/v3/index.json

Restart-Computer
