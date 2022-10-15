
$workDir = [System.IO.Path]::GetDirectoryName($PSCommandPath)

Set-Location $workDir

. ..\Test-Administrator.ps1

if (Test-Administrator) {   

    $update = Get-WindowsUpdate

    while($update.count -ne 0){
    
        $update

        Install-WindowsUpdate -AcceptAll -MicrosoftUpdate -AutoReboot
        
        $update = Get-WindowsUpdate
    }

}
else {
    Start-Process Powershell -Verb RunAs -ArgumentList " $PSCommandPath ''" 
}
