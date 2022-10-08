$workDir = [System.IO.Path]::GetDirectoryName($PSCommandPath)
  
Set-Location $workDir

. ..\Test-Administrator.ps1

if (Test-Administrator) {   

    $date = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
    $VMName = "Win-10-$date"
    $VMPath = 'D:\Hyper'

    $VM = Import-VM `
        -Path "*****************\Virtual Machines\AB42A00A-73FC-43C7-B2DF-7266363817EF.vmcx" `
        -Copy `
        -GenerateNewId `
        -VhdDestinationPath "$VMPath\$VMName" `
        -VirtualMachinePath "$VMPath\$VMName"

    Rename-VM $VM -NewName $VMName
 
}
else {
    Start-Process Powershell -Verb RunAs -ArgumentList " $PSCommandPath ''" 
}
