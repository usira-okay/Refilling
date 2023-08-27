Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Visual Studio'
Invoke-WebRequest -Uri https://aka.ms/vs/17/release/vs_community.exe -OutFile .\vs_community.exe

$process = Start-Process -FilePath vs_community.exe -ArgumentList "--allWorkloads", "--passive", "--installWhileDownloading", "--locale en-US", "--wait" -Wait -PassThru
Write-Output $process.ExitCode 

Invoke-WebRequest -Uri https://aka.ms/vs/17/release/vs_BuildTools.exe -OutFile .\vs_buildtools.exe

$process = Start-Process -FilePath vs_buildtools.exe -ArgumentList "--allWorkloads", "--passive", "--installWhileDownloading", "--locale en-US", "--wait", "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64" -Wait -PassThru
Write-Output $process.ExitCode 


Pause
