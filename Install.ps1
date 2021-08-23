# Add US and TW Keyboard
$UserLanguageList = New-WinUserLanguageList -Language "zh-TW"
$UserLanguageList.Add("en-US")
Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
Set-WinDefaultInputMethodOverride -InputTip "0409:00000409"

# Install Applications by Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install googlechrome line teamviewer telegram 7zip adobereader libreoffice-fresh discord postman vscode nodejs git sourcetree visualstudio2019community sql-server-management-studio potplayer microsoft-teams docker-desktop wsl2 powertoys openshot obs-studio -y
choco install dotnetcore-sdk --version=2.1.502 -y
# Refresh Chocolatey environment 
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   

Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

refreshenv

# Install develoment tools
npm install -g @angular/cli
code --install-extension "shan.code-settings-sync"
npm i -g nswag
npm install -g ng-openapi-gen
