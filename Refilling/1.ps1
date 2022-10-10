$workDir = [System.IO.Path]::GetDirectoryName($PSCommandPath)

Set-Location $workDir

. ..\Test-Administrator.ps1

if (Test-Administrator) {   

    #以系統管理者權限開啟 Powershell 並執行以下指令

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
