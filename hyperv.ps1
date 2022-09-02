$VMName = 'Win-10-01'
$SWName = 'Default Switch'
$VMPath = 'D:\Hyper'
$ISOPath = "E:\Cloud\Windows\Windows.iso"

$GiB = 1024 * 1024 * 1024

# 儲存建立的 VM 物件，可以方便後續進行設定
$VM = New-VM -Name $VMName -SwitchName $SWName -Path $VMPath `
    -NewVHDPath "${VMPath}\${VMName}\Virtual Hard Disks\${VMName}.vhdx" `
    -MemoryStartupBytes ([int64]24 * $GiB) -Generation 1 -NewVHDSizeBytes ([int64]100 * $GiB)
$VM | Set-VMProcessor -Count 12
$VM | Set-VMProcessor -ExposeVirtualizationExtensions $true
$VM | Set-VMMemory -DynamicMemoryEnabled $true
$VM | Get-VMDvdDrive | Set-VMDvdDrive -Path $ISOPath
$VM | Start-VM
