# Refilling

Windows 開發環境自動化佈建工具。透過編號化的 PowerShell 腳本，快速建立完整的開發環境。

## 系統需求

- Windows 10/11
- PowerShell 5.1 或 PowerShell 7+
- 網路連線（安裝應用程式需要）

## 快速開始

1. 開啟 PowerShell，手動執行以下指令設定 ExecutionPolicy：
   （內容來自 `0 - Set ExecutionPolicy - 手動執行.ps1`）
2. 以管理員身份依序執行腳本 1-5

## 腳本說明

| 腳本 | 說明 |
|------|------|
| `0 - Set ExecutionPolicy - 手動執行.ps1` | 設定 PowerShell 執行策略為 ByPass，停用 Print Screen 快捷鍵 |
| `1 - Set System.ps1` | 系統設定：語言（繁中+英文）、電源管理、剪貼板歷史、WSL2/Hyper-V、Explorer 設定 |
| `2 - Install Applications (Winget & Chocolatey).ps1` | 透過 Winget 匯入應用清單、安裝 Visual Studio Community、安裝 Chocolatey 及其套件 |
| `3 - Install Applications (Scoop).ps1` | 安裝 Scoop 套件管理器、Maple Mono NF CN 字型、oh-my-posh |
| `4 - nvm.ps1` | 透過 NVM 安裝最新版 Node.js |
| `5 - Other Install And Settings.ps1` | NuGet、dotnet-ef、AutoHotKey 啟動、Git 設定、PowerShell Profile、Windows Terminal 設定、git_worktree_copse |

## 設定檔

使用前請先修改 `config.ps1` 中的個人資訊：

- `GitName` — Git 使用者名稱
- `GitEmail` — Git 電子郵件
- `SshKeySource` — SSH 金鑰來源路徑
- `DesktopPath` — 自訂桌面路徑
- `ScoopCachePath` — Scoop 快取路徑

## 可選腳本（Optional/）

| 腳本 | 說明 |
|------|------|
| `Change Cursors.ps1` | 更改系統游標主題（Numix Dark） |
| `Change Remote Port.ps1` | 修改遠端桌面連線埠 |
| `Set Desktop.ps1` | 修改桌面資料夾位置 |
| `Set User Password.ps1` | 修改本機使用者密碼 |
| `Set-SSH.ps1` | 配置 SSH 金鑰與 ssh-agent |
| `Windows Button.ps1` | 隱藏關機與睡眠按鈕 |
| `set-asus-ime.ps1` | 安裝華碩注音輸入法（取代微軟新注音） |

## WSL 環境設定（wsl/）

WSL 腳本用於初始化 Linux 開發環境：

| 腳本 | 說明 |
|------|------|
| `init.sh` | 主入口，依序呼叫各模組 |
| `dotnet.sh` | 安裝 .NET SDK 6/8/9/10 |
| `ssh.sh` | SSH 金鑰生成 |

使用前請修改 `wsl/config.sh` 中的個人資訊。

## 其他

- **AutoHotKey/** — Windows 快捷鍵配置（Ctrl+Alt+Win 系列）
- **Cursors/** — Numix Dark/Light 游標主題檔案
- **Winget Package/** — Winget 應用匯入清單（Tools.json）
- **docker/** — Docker Compose 部署配置
