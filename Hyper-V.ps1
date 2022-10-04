$workDir = [System.IO.Path]::GetDirectoryName($PSCommandPath)
  
Set-Location $workDir

. .\Test-Administrator.ps1

if (Test-Administrator) {   

    $date = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
    $VMName = "Win-10-$date"
    $SWName = 'Default Switch'
    $VMPath = 'D:\Hyper'
    $ISOPath = "D:\Windows.iso"

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
