
Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. ..\Test-Admin.ps1 -p $PSCommandPath
. ..\config.ps1

Write-Host 'Set Desktop'

# 1. 設定你想要的新桌面路徑
$newPath = $Config.DesktopPath

# 2. 檢查資料夾是否存在
if (!(Test-Path -Path $newPath)) {
    # 如果找不到資料夾，直接報錯並終止執行
    Write-Error "錯誤：找不到目標資料夾 '$newPath'。操作已取消，未對系統進行任何變更。"
    exit
}

# 3. 執行到這裡代表資料夾存在，開始修改登錄檔
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"

try {
    # 修改桌面路徑 (使用 REG_EXPAND_SZ 以相容環境變數)
    Set-ItemProperty -Path $registryPath -Name "Desktop" -Value $newPath -ErrorAction Stop
    
    Write-Host "成功：桌面路徑已更新為 '$newPath'。" -ForegroundColor Green

    # 4. 立即重啟檔案總管使設定生效
    Write-Host "正在重新啟動檔案總管以套用變更..."
    Stop-Process -Name explorer -Force
    Start-Process explorer
}
catch {
    Write-Error "變更登錄檔時發生預料之外的錯誤：$($_.Exception.Message)"
}
        
Pause
