function Test-Administrator { $user = [Security.Principal.WindowsIdentity]::GetCurrent(); (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) } 

if (Test-Administrator){   

Set-ExecutionPolicy Unrestricted

dism.exe /online /enable-feature:Microsoft-Windows-Subsystem-Linux /all /norestart

dism.exe /online /enable-feature:VirtualMachinePlatform /all /norestart

dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All /norestart

Restart-Computer

}else{
    Write-Host "Not admin!"
}
