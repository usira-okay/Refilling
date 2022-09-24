function Test-Administrator {
    Write-Host 'Test-Administrator'
    # Test-Administrator
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) 
} 

$workDir = [System.IO.Path]::GetDirectoryName($PSCommandPath)
  
Set-Location $workDir

if (Test-Administrator) {   

    $VMName = 'Win-10-01'
    $SWName = 'Default Switch'
    $VMPath = 'D:\Hyper'
    $ISOPath = "E:\Cloud\Windows\Windows.iso"

    $GiB = 1024 * 1024 * 1024
    $disk = 100
    $memory = 2
    $CPUCount = 10

    # 儲存建立的 VM 物件，可以方便後續進行設定
    $VM = New-VM -Name $VMName -SwitchName $SWName -Path $VMPath `
        -NewVHDPath "${VMPath}\${VMName}\Virtual Hard Disks\${VMName}.vhdx" `
        -MemoryStartupBytes ([int64]$memory * $GiB) -Generation 1 -NewVHDSizeBytes ([int64]$disk * $GiB)
    $VM | Set-VMProcessor -Count $CPUCount
    $VM | Set-VMProcessor -ExposeVirtualizationExtensions $true
    $VM | Set-VMMemory -DynamicMemoryEnabled $true
    $VM | Get-VMDvdDrive | Set-VMDvdDrive -Path $ISOPath
    $VM | Start-VM

}
else {
    Start-Process Powershell -Verb RunAs -ArgumentList " $PSCommandPath ''" 
}
