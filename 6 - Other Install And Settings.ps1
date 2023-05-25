Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Other install and settings'

if (!($env:Path.Contains('C:\Program Files\Git\bin'))) {
    $env:Path
    
    if (!$env:Path.EndsWith(';')) {
        $env:Path = $env:Path + ';'
    }
    $env:Path = $env:Path + "C:\Users\$env:USERNAME\scoop\apps\git\current\bin"

    $env:Path
}

Write-Host 'Install AzureCLI'
# Install AzureCLI
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi
   
Write-Host 'Install-Module Az'
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

Pause
