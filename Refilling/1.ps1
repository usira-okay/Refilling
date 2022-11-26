$workDir = [System.IO.Path]::GetDirectoryName($PSCommandPath)

Set-Location $workDir

. ..\Functions.ps1

if (Test-Administrator) {   

    dism.exe /online /enable-feature:Microsoft-Windows-Subsystem-Linux /all /norestart

    dism.exe /online /enable-feature:VirtualMachinePlatform /all /norestart

    dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All /norestart

    dism.exe /online /Enable-Feature:Containers-DisposableClientVM /All /norestart

    Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force

    Install-Module PSWindowsUpdate -Force

    Import-Module PSWindowsUpdate  -Force

    UpdateWindows
}
else {
    Start-Process Powershell -Verb RunAs -ArgumentList " $PSCommandPath ''" 
}
