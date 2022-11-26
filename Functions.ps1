function Test-Administrator {
    Write-Host 'Test-Administrator'
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) 
} 

function UpdateWindows {
    Write-Host 'UpdateWindows'

    $update = Get-WindowsUpdate

    while ($update.count -ne 0) {
    
        $update

        Install-WindowsUpdate -AcceptAll -MicrosoftUpdate -AutoReboot
        
        $update = Get-WindowsUpdate
    }
 
} 