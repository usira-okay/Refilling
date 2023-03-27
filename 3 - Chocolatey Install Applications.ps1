Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Install Applications by Chocolatey'
# Install Applications by Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install tortoisegit `
    sizer `
    sqlpackage `
    line `
    adobereader `
    nuget.commandline `
    drawio `
    googledrive `
    devtoys `
    sql-server-management-studio `
    libreoffice-still `
    vscode `
    vlc `
    winrar `
    7zip `
    visualstudio2022community --package-parameters '--allWorkloads --passive --locale en-US' -y

Pause
