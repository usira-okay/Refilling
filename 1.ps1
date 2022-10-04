$workDir = [System.IO.Path]::GetDirectoryName($PSCommandPath)

Set-Location $workDir

. .\Test-Administrator.ps1

if (Test-Administrator) {   

    dism.exe /online /enable-feature:Microsoft-Windows-Subsystem-Linux /all /norestart

    dism.exe /online /enable-feature:VirtualMachinePlatform /all /norestart

    dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All /norestart

    dism.exe /online /Enable-Feature:Containers-DisposableClientVM /All /norestart

    Restart-Computer

}
else {
    Start-Process Powershell -Verb RunAs -ArgumentList " $PSCommandPath ''" 
}
