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

# Install SWA CLI
npm install -g @azure/static-web-apps-cli

# Add Nuget Offical Source
nuget source add -name nuget -source https://api.nuget.org/v3/index.json

Install-Module posh-git -Scope CurrentUser -Force
    
if (Test-Path -Path $PROFILE) { Remove-Item -Path $PROFILE -Force }

New-Item -Type File -Path $PROFILE -Force

"Invoke-Expression (&starship init powershell)" | Out-File -FilePath $PROFILE

dotnet tool install --global dotnet-ef

Pause
