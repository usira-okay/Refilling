#requires -Version 7.0
if (-not (. (Join-Path $PSScriptRoot 'Common.ps1') -CallerPath $PSCommandPath)) { return }

Write-Host '設定 Windows 系統'

# 先檢查全部必要功能，缺少功能時不得先套用其他系統設定。
$features = @(
    'Microsoft-Windows-Subsystem-Linux',
    'VirtualMachinePlatform',
    'Microsoft-Hyper-V',
    'Containers',
    'Containers-DisposableClientVM'
)
$availableFeatures = @(Get-WindowsOptionalFeature -Online)
$missingFeatures = @($features | Where-Object { $_ -notin $availableFeatures.FeatureName })
if ($missingFeatures.Count -gt 0) {
    throw "此 Windows 系統缺少必要功能：$($missingFeatures -join ', ')。尚未套用系統設定。"
}

Write-Host '加入臺灣與美國鍵盤配置'
$UserLanguageList = New-WinUserLanguageList -Language 'zh-TW'
$UserLanguageList.Add('en-US')
Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
Set-WinDefaultInputMethodOverride -InputTip '0409:00000409'

# 設定地區、語言
Set-WinHomeLocation -GeoId 237
Set-Culture -CultureInfo 'zh-TW'

# 停用預設的 Print Screen 快捷鍵，交由自訂快捷鍵處理。
Set-ItemProperty -Path 'HKCU:\Control Panel\Keyboard' -Name PrintScreenKeyForSnippingEnabled -Value 0

# 調整電腦進入睡眠時間
# 電池
Invoke-ExternalCommand -FilePath powercfg -ArgumentList @('-change', '-standby-timeout-dc', '120')
# 插電
Invoke-ExternalCommand -FilePath powercfg -ArgumentList @('-change', '-standby-timeout-ac', '0')

# 調整電腦關閉螢幕時間
# 電池
Invoke-ExternalCommand -FilePath powercfg -ArgumentList @('-change', '-monitor-timeout-dc', '30')
# 插電
Invoke-ExternalCommand -FilePath powercfg -ArgumentList @('-change', '-monitor-timeout-ac', '60')

# 開啟 Win + V 剪貼簿歷程記錄。
Invoke-ExternalCommand -FilePath reg -ArgumentList @(
    'add', 'HKEY_CURRENT_USER\Software\Microsoft\Clipboard', '/t', 'REG_DWORD',
    '/v', 'EnableClipboardHistory', '/d', '1', '/f'
)

# 啟用 Windows 功能（已啟用則跳過）
foreach ($feature in $features) {
    $state = ($availableFeatures | Where-Object { $_.FeatureName -eq $feature }).State
    if ($state -eq 'Enabled') {
        Write-Host "$feature 已啟用，跳過" -ForegroundColor Yellow
    } else {
        Write-Host "啟用 $feature ..."
        # DISM 的 3010 表示成功且需要重新開機。
        Invoke-ExternalCommand -FilePath dism.exe -ArgumentList @(
            '/online', "/enable-feature:$feature", '/all', '/norestart'
        ) -SuccessExitCodes @(0, 3010)
    }
}

# 單擊開檔
$explorerKey = 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer'
Invoke-ExternalCommand -FilePath reg -ArgumentList @('add', $explorerKey, '/v', 'IconUnderline', '/t', 'REG_DWORD', '/d', '2', '/f')
Invoke-ExternalCommand -FilePath reg -ArgumentList @(
    'add', $explorerKey, '/v', 'ShellState', '/t', 'REG_BINARY', '/d',
    '240000001ea8000000000000000000000000000001000000130000000000000062000000', '/f'
)

# 顯示隱藏檔案
$explorerAdvancedKey = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Invoke-ExternalCommand -FilePath reg -ArgumentList @('add', $explorerAdvancedKey, '/v', 'Hidden', '/t', 'REG_DWORD', '/d', '1', '/f')
Invoke-ExternalCommand -FilePath reg -ArgumentList @('add', $explorerAdvancedKey, '/v', 'ShowSuperHidden', '/t', 'REG_DWORD', '/d', '1', '/f')

# 顯示已知的檔案類型
Invoke-ExternalCommand -FilePath reg -ArgumentList @('add', $explorerAdvancedKey, '/v', 'HideFileExt', '/t', 'REG_DWORD', '/d', '0', '/f')

# 檔案路徑長度
Invoke-ExternalCommand -FilePath reg -ArgumentList @(
    'add', 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem',
    '/v', 'LongPathsEnabled', '/t', 'REG_DWORD', '/d', '1', '/f'
)

$restartAnswer = Read-Host '系統設定已完成。現在重新啟動？請輸入 Y 確認；其他輸入略過'
if ($restartAnswer -ceq 'Y') {
    Invoke-ExternalCommand -FilePath shutdown -ArgumentList @('-r', '-t', '0')
} else {
    Write-Host '請儲存工作並手動重新啟動，再繼續第 2 階段。'
}
