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
dotnet nuget add source --name nuget.org https://api.nuget.org/v3/index.json

dotnet tool install --global dotnet-ef

Copy-Item .\AutoHotKey\autohotkey.ahk "C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey.ahk"

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\PowerToys.lnk")
$Shortcut.TargetPath = "C:\Users\$env:USERNAME\scoop\apps\powertoys\current\PowerToys.exe"
$Shortcut.Save()

$webClient = New-Object System.Net.WebClient
$url = 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.13.4-stable.zip'
$destination = 'flutter.zip'
$webClient.DownloadFile($url, $destination)

Expand-Archive -Path 'flutter.zip' -DestinationPath 'flutter'


Copy-Item -Path 'flutter\flutter' -Destination 'C:\tools\flutter' -Recurse

$env:path
$envPath = $env:path
$splitPaths = $envPath -split ';' | Where-Object { $_ -ne '' }

$targetPath = "C:\Program Files\Oracle\VirtualBox"

if ($splitPaths -notcontains $targetPath) {
    $splitPaths += $targetPath
}

$flutterPath = 'C:\tools\flutter\bin'

if ($splitPaths -notcontains $flutterPath) {
    $splitPaths += $flutterPath
}

$env:path = ($splitPaths -join ';') + ';'

$env:path

git config --global user.name "Ari"
git config --global user.email "arisuokayokay@gmail.com"

Pause
