Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Visual Studio'


$command = "--allWorkloads --passive --installWhileDownloading --locale en-US --wait --norestart"

winget install --id Microsoft.VisualStudio.2022.Community --override $command --accept-package-agreements --accept-source-agreements

Pause
