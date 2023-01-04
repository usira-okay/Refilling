Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Install Applications by Chocolatey'
# Install Applications by Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install tortoisegit `
    sizer `
    sqlpackage `
    brave `
    line `
    teamviewer `
    7zip `
    adobereader `
    postman `
    vscode `
    nodejs-lts `
    git `
    git-lfs `
    sourcetree `
    potplayer `
    zoom `
    ngrok `
    filezilla `
    yt-dlp `
    ffmpeg `
    flameshot `
    devtoys `
    coretemp `
    nuget.commandline `
    speedtest-by-ookla `
    sql-server-management-studio `
    powertoys `
    drawio `
    googledrive `
    obsidian `
    microsoft-openjdk `
    maven `
    docker-desktop `
    slack `
    visualstudio2019community --package-parameters '--allWorkloads --passive --locale en-US' `
    visualstudio2022community --package-parameters '--allWorkloads --passive --locale en-US' -y

# Refresh Chocolatey environment 
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

refreshenv

# Install develoment tools
code --install-extension 'shan.code-settings-sync'

# Install SWA CLI
npm install -g @azure/static-web-apps-cli

# Add Nuget Offical Source
nuget source add -name nuget -source https://api.nuget.org/v3/index.json
    
Pause
