Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Set System'

Write-Host 'Add US and TW Keyboard'
# Add US and TW Keyboard
$UserLanguageList = New-WinUserLanguageList -Language 'zh-TW'
$UserLanguageList.Add('en-US')
Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
Set-WinDefaultInputMethodOverride -InputTip '0409:00000409'

# 調整電腦進入睡眠時間
# 電池
powercfg -change -standby-timeout-dc 120
# 插電
powercfg -change -standby-timeout-ac 0

# 調整電腦關閉螢幕時間
# 電池
powercfg -change -monitor-timeout-dc 30
# 插電
powercfg -change -monitor-timeout-ac 60

# 開啟 Win + v 
reg add HKEY_CURRENT_USER\Software\Microsoft\Clipboard /t REG_DWORD /v EnableClipboardHistory /d 1 /f

dism.exe /online /enable-feature:Microsoft-Windows-Subsystem-Linux /all /norestart

dism.exe /online /enable-feature:VirtualMachinePlatform /all /norestart

dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All /norestart

dism.exe /online /Enable-Feature:Containers /All /norestart

Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force

Install-Module PSWindowsUpdate -Force

Import-Module PSWindowsUpdate  -Force
  
shutdown -r -t 120 -f

Pause
