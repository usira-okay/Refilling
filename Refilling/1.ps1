$workDir = [System.IO.Path]::GetDirectoryName($PSCommandPath)

Set-Location $workDir

. ..\Test-Administrator.ps1

if (Test-Administrator) {   

    dism.exe /online /enable-feature:Microsoft-Windows-Subsystem-Linux /all /norestart

    dism.exe /online /enable-feature:VirtualMachinePlatform /all /norestart

    dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All /norestart

    dism.exe /online /Enable-Feature:Containers-DisposableClientVM /All /norestart

    # 以下是 Windows Update

    Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope CurrentUser -Force

    Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force

    Install-Module PSWindowsUpdate -Force

    Import-Module PSWindowsUpdate  -Force

    Get-WindowsUpdate  -ForceDownload -ForceInstall

    Install-WindowsUpdate  -ForceDownload -ForceInstall

    Restart-Computer

}
else {
    Start-Process Powershell -Verb RunAs -ArgumentList " $PSCommandPath ''" 
}
