Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. ..\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Change Remote Port'

$portvalue = 3390

# 變更遠端桌面的 Port 以及變更遠端桌面的 Port
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name 'PortNumber' -Value $portvalue 
New-NetFirewallRule -DisplayName 'RDPPORTLatest-TCP-In' -Profile 'Public' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $portvalue 
New-NetFirewallRule -DisplayName 'RDPPORTLatest-UDP-In' -Profile 'Public' -Direction Inbound -Action Allow -Protocol UDP -LocalPort $portvalue

# 開啟遠端桌面功能
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0

Pause
