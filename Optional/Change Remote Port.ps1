#requires -Version 7.0
<# .SYNOPSIS 驗證 RDP 連接埠，更新固定名稱的 TCP／UDP 防火牆規則並啟用遠端桌面。 #>
$repositoryRoot = Split-Path $PSScriptRoot -Parent
if (-not (. (Join-Path $repositoryRoot 'Common.ps1') -CallerPath $PSCommandPath)) { return }

$portInput = Read-Host '請輸入 RDP 連接埠（1–65535）'
$portValue = 0
if (-not [int]::TryParse($portInput, [ref]$portValue) -or $portValue -lt 1 -or $portValue -gt 65535) {
    throw 'RDP 連接埠必須是 1–65535 的整數。'
}

# 先查詢現有規則；查詢失敗會中止，避免把讀取錯誤當成規則不存在。
$existingRules = @(Get-NetFirewallRule)
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name PortNumber -Value $portValue
foreach ($protocol in @('TCP', 'UDP')) {
    $rule = @{
        Name = "Refilling-RDP-$protocol-In"
        Profile = @('Private', 'Public')
        Direction = 'Inbound'
        Action = 'Allow'
        Protocol = $protocol
        LocalPort = $portValue
        Enabled = 'True'
    }
    if ($existingRules.Name -contains $rule.Name) {
        Set-NetFirewallRule @rule
    } else {
        New-NetFirewallRule @rule -DisplayName $rule.Name | Out-Null
    }
}

Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0
Write-Host "RDP 已設定為連接埠 $portValue，請重新啟動電腦後使用新連接埠連線。" -ForegroundColor Green
Pause
