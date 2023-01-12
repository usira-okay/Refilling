Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Install Applications by Chocolatey'
# Install Applications by Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install tortoisegit `
    sizer `
    sqlpackage `
    googlechrome `
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
    gsudo `
    dbeaver `
    crystaldiskinfo `
    winrar `
    visualstudio2019community --package-parameters '--allWorkloads --passive --locale en-US' `
    visualstudio2022community --package-parameters '--allWorkloads --passive --locale en-US' -y

Pause
