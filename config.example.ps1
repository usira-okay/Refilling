# Refilling 專案設定檔範本
# 使用前請先複製此檔案為 config.ps1，並依個人環境修改以下設定值
# config.ps1 已被 .gitignore 排除，不會被提交到版本控制

$Config = @{
    # Git 設定
    GitName  = 'your-name'
    GitEmail = 'you@example.com'

    # SSH 金鑰來源路徑
    SshKeySource = 'C:\path\to\your\ssh\keys'

    # 桌面資料夾路徑（Optional/Set Desktop.ps1 使用）
    DesktopPath = 'D:\MyNewDesktop'

    # Scoop 快取路徑
    ScoopCachePath = 'C:\ScoopCache'
}
