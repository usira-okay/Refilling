Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Visual Studio'
Invoke-WebRequest -Uri https://aka.ms/vs/17/release/vs_community.exe -OutFile .\vs_community.exe

$process = Start-Process -FilePath vs_community.exe -ArgumentList "--allWorkloads", "--passive", "--installWhileDownloading", "--locale en-US", "--wait" -Wait -PassThru
Write-Output $process.ExitCode 

Pause
