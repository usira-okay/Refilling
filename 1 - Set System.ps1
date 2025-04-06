Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Set System'

Write-Host 'Add US and TW Keyboard'
# Add US and TW Keyboard
$UserLanguageList = New-WinUserLanguageList -Language 'zh-TW'
$UserLanguageList.Add('en-US')
Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
Set-WinDefaultInputMethodOverride -InputTip '0409:00000409'

# 設定地區、語言
Set-WinHomeLocation -GeoId 237
Set-Culture -CultureInfo "zh-TW"


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

dism.exe /online /Enable-Feature:Containers-DisposableClientVM /All /norestart

# 單擊開檔
REG ADD 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer' /V IconUnderline /T REG_DWORD /D 2 /F
REG ADD 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer' /V ShellState /T REG_BINARY /D 240000001ea8000000000000000000000000000001000000130000000000000062000000 /F

# 顯示隱藏檔案
REG ADD 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /V Hidden /T REG_DWORD /D 1 /F
REG ADD 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /V ShowSuperHidden /T REG_DWORD /D 1 /F

# 顯示已知的檔案類型
REG ADD 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /V HideFileExt /T REG_DWORD /D 0 /F

Pause

shutdown -r -t 0 -f