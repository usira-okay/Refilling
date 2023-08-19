Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Other install and settings'

Write-Host 'AzureCLI'
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi

Write-Host 'PackageProvider Nuget'
Install-PackageProvider -Name Nuget -Force

Write-Host 'Az'
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

Write-Host 'Add Nuget Offical Source'
nuget source add -name nuget -source https://api.nuget.org/v3/index.json

dotnet tool install --global dotnet-ef

Copy-Item .\AutoHotKey\autohotkey.ahk "C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey.ahk"

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\PowerToys.lnk")
$Shortcut.TargetPath = "C:\Users\$env:USERNAME\scoop\apps\powertoys\current\PowerToys.exe"
$Shortcut.Save()

$env:path
$envPath = $env:path
$splitPaths = $envPath -split ';' | Where-Object { $_ -ne '' }

$targetPath = "C:\Program Files\Oracle\VirtualBox"

if ($splitPaths -notcontains $targetPath) {
    $splitPaths += $targetPath
}

$env:path = ($splitPaths -join ';') + ';'

$env:path

git config -g user.name "Ari"
git config -g user.email "arisuokayokay@gmail.com"

Pause
