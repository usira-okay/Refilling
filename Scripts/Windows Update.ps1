Write-Host 'Update Windows'

$update = Get-WindowsUpdate

while ($update.count -ne 0) {
    
    $update

    Install-WindowsUpdate -AcceptAll -MicrosoftUpdate -AutoReboot
        
    $update = Get-WindowsUpdate
}
