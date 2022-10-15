
$workDir = [System.IO.Path]::GetDirectoryName($PSCommandPath)

Set-Location $workDir

. ..\Test-Administrator.ps1

if (Test-Administrator) {   

    Get-WindowsUpdate

    Install-WindowsUpdate -AcceptAll -MicrosoftUpdate -AutoReboot

}
else {
    Start-Process Powershell -Verb RunAs -ArgumentList " $PSCommandPath ''" 
}
