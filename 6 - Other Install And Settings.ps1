Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Other install and settings'

# Install AzureCLI
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi
   
# Install-Module Az
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

# Install SWA CLI
npm install -g @azure/static-web-apps-cli

# Add Nuget Offical Source
nuget source add -name nuget -source https://api.nuget.org/v3/index.json

dotnet tool install --global dotnet-ef

Copy-Item .\AutoHotKey\autohotkey.ahk "C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey.ahk"

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\PowerToys.lnk")
$Shortcut.TargetPath = "C:\Users\$env:USERNAME\scoop\apps\powertoys\current\PowerToys.exe"
$Shortcut.Save()

# Install visual studio
Invoke-WebRequest -Uri https://aka.ms/vs/17/release/vs_community.exe -OutFile .\vs_community.exe

$process = Start-Process -FilePath vs_community.exe -ArgumentList "--allWorkloads", "--passive", "--installWhileDownloading", "--locale en-US", "--wait" -Wait -PassThru
Write-Output $process.ExitCode 

Pause
