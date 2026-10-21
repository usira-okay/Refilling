# Refilling

Windows 開發環境佈建腳本。依序完成系統設定、應用程式安裝、Node.js、Git、PowerShell 個人環境與 Windows Terminal 設定。

## 支援範圍

- **Windows 11 Pro x64 乾淨新機**，具備管理員權限及網路連線。
- 第 0 階段使用內建 Windows PowerShell 5.1 引導安裝；其餘腳本使用 **PowerShell 7**。
- 本流程以首次佈建為目標。失敗時停止並顯示錯誤；請確認原因後再執行，沒有整批復原或從中斷處自動續跑的機制。

## 開始使用

1. 將 `config.example.ps1` 複製為 `config.ps1`，填寫 Git 名稱、電子郵件及所需路徑。`config.ps1` 已排除於版本控制。
2. 在專案目錄開啟內建 Windows PowerShell，執行引導腳本：

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File '.\0 - Set ExecutionPolicy - 手動執行.ps1'
   ```

   引導會先檢查 Windows 版本與架構，再設定目前使用者的執行原則為 `Bypass`、確認 WinGet 並安裝 PowerShell 7。若缺少 App Installer，依錯誤訊息完成安裝後重試。

3. 關閉原視窗，從開始功能表開啟一般權限的 **PowerShell 7**，切換至專案目錄：

   ```powershell
   & '.\1 - Set System.ps1'
   ```

   第 1、2 階段會自行開啟管理員視窗；請等該視窗中的腳本完成。第 1 階段只有輸入大寫 `Y` 才立即重新啟動，其他輸入都保留工作階段；如略過，請自行儲存工作並重新啟動後再進行第 2 階段。

4. 依序執行以下階段，每個階段完成後才繼續。第 2 階段安裝工具、第 3 階段安裝 Scoop、第 4 階段切換 Node.js 後，重新開啟一般權限的 PowerShell 7，讓後續命令取得新的 PATH。

   ```powershell
   & '.\2 - Install Applications (Winget & Chocolatey).ps1'
   & '.\3 - Install Applications (Scoop).ps1'
   & '.\4 - nvm.ps1'
   & '.\5 - Other Install And Settings.ps1'
   ```

   上述指令請分次執行。Scoop 必須使用一般權限視窗；第 5 階段也應在目前使用者的一般權限視窗執行。

可從其他工作目錄以完整路徑呼叫腳本；設定檔與資源一律相對於腳本所在位置讀取。

## 各階段工作

| 腳本 | 工作 | 權限 |
| --- | --- | --- |
| `0 - Set ExecutionPolicy - 手動執行.ps1` | 檢查 Win11 Pro x64、引導 WinGet 與 PowerShell 7 | 一般權限，安裝程式可能要求提權 |
| `1 - Set System.ps1` | 繁中／英文鍵盤、電源、剪貼簿、Print Screen、Explorer、長路徑、WSL2／Hyper-V／Sandbox | 自動提權；確認後才重新啟動 |
| `2 - Install Applications (Winget & Chocolatey).ps1` | WinGet 應用清單、Visual Studio C++ Build Tools、Chocolatey 的 FileZilla | 自動提權 |
| `3 - Install Applications (Scoop).ps1` | Scoop、Maple Mono NF CN 字型、oh-my-posh | 一般權限 |
| `4 - nvm.ps1` | NVM 安裝及切換最新版 Node.js | 一般權限；NVM 建立連結時可能要求提權 |
| `5 - Other Install And Settings.ps1` | NuGet、dotnet-ef、登入啟動、Git、PSReadLine、Terminal-Icons、個人 Profile、Terminal、git_worktree_copse、Yarn | 一般權限 |

`Common.ps1`、`Test-Admin.ps1`、`ScriptHelpers.ps1` 與 `TerminalSettings.ps1` 是內部共用函式，不需自行執行。外部程式失敗會回報命令與結束碼並停止後續流程；DISM 的 `3010` 視為成功且需要重新啟動。

### 套件來源

目前由 Chocolatey 安裝的套件已依來源可用性調整：

| 程式 | 安裝來源 | 套件 |
| --- | --- | --- |
| FFmpeg | WinGet community | `Gyan.FFmpeg` |
| AutoHotkey | WinGet community | `AutoHotkey.AutoHotkey`，固定穩定 v2 `2.0.30` |
| LINE 桌面版 | WinGet Microsoft Store | `XPFCC4CD725961` |
| FileZilla Client | Chocolatey | `filezilla` |

FileZilla Client 不在 WinGet community 套件庫中，因此保留 Chocolatey。[WinGet 官方排除清單](https://github.com/microsoft/winget-pkgs/blob/master/.github/policies/flaggedPackages.yml)

套件清單位於 `Winget Package/Tools.json`。來源、版本或架構沒有相符套件時，才選用 Chocolatey；網路、下載或安裝失敗會停止，**不會自動改用另一個套件管理器重試**。新增套件時應先查證來源再修改清單。

### 個人環境與 Terminal

第 5 階段會將 v2 腳本複製至目前使用者的 Startup，並從實際安裝位置建立 PowerToys 捷徑；不再建立 Flameshot 捷徑。

個人 Profile 位於 `$env:USERPROFILE\Microsoft.PowerShell_profile.ps1`。現有 Profile 會先備份；內容包含 oh-my-posh、Terminal-Icons、Docker、worktree 與原有 AI CLI 快捷函式。

Terminal 使用穩定版 `Microsoft.WindowsTerminal_8wekyb3d8bbwe` 的 `LocalState\settings.json`，支援首次尚未產生設定檔的情況。更新前先驗證 JSON 與必要結構，保存原始備份，再寫入完整的新設定。損壞或不相容的結構會停止，不會以空設定覆蓋。

PowerShell 7 與 agent-dev 排在清單前兩位，使用 Maple Mono NF CN，並將 PowerShell 7 設為預設。既有 GUID、其他 profiles 與個人設定會保留；PS7 的個人 Profile 不會套用至舊版 Windows PowerShell。

## 設定檔

| 欄位 | 用途 |
| --- | --- |
| `GitName`、`GitEmail` | Git 名稱與電子郵件，不能空白 |
| `SshKeySource` | Optional SSH 金鑰來源資料夾 |
| `DesktopPath` | Optional 桌面位置，應填入實際存在的資料夾 |
| `ScoopCachePath` | Scoop 快取路徑 |

## 可選腳本

`Optional/` 腳本依需求個別執行，需先完成主流程並使用 PowerShell 7。

| 腳本 | 工作 |
| --- | --- |
| `Change Cursors.ps1` | 套用 Numix Dark 游標主題 |
| `Change Remote Port.ps1` | 修改遠端桌面連接埠及防火牆規則 |
| `Set Desktop.ps1` | 修改桌面資料夾位置 |
| `Set User Password.ps1` | 修改本機使用者密碼 |
| `Set-SSH.ps1` | 配置 SSH 金鑰與 ssh-agent |
| `Windows Button.ps1` | 隱藏關機與睡眠按鈕 |
| `set-asus-ime.ps1` | 設定已安裝的華碩注音輸入法；安裝由第 2 階段的 Store 套件處理 |
| `Setup AI Environment.ps1` | 安裝 Claude Code、Codex、GitHub Copilot、Antigravity，透過 npx 安裝 skills，並將 `AGENTS.md` 覆寫至各 CLI 全域指令檔 |

## AutoHotkey v2 快捷鍵

`AutoHotKey/autohotkey.ahk` 使用 `#Requires AutoHotkey v2.0`，無法由 v1 執行。完成第 5 階段後，重新登入即可由 Startup 載入，也可自行雙擊腳本啟動。

| 快捷鍵 | 動作 |
| --- | --- |
| Ctrl + Win + Alt + A | 取消排程關機／重新啟動 |
| Ctrl + Win + Alt + R | 10 秒後強制重新啟動，保留原快捷鍵行為 |
| Ctrl + Win + Alt + S | 10 秒後強制關機，保留原快捷鍵行為 |
| Win + Alt + P | 輸入「，再麻煩協助 review & merge 感謝」 |
| Win + Alt + X | 載入個人 Profile 並進入 agent-dev 容器 |
| Win + Alt + C | 在 Explorer 所在資料夾開啟 PowerShell 7 |
| Win + Alt + Space | 同上，以管理員權限開啟 |
| Win + Alt + V | 以 VS Code 開啟 Explorer 所在資料夾 |

未處於 Explorer 實體資料夾時使用桌面。路徑中的空白、繁中、單引號與中括號會作為路徑字面值處理。Explorer 多分頁與 UAC 行為需在 Windows 實機驗收。

## 開發驗證

使用 PowerShell 7.2 以上，安裝測試工具後執行：

```powershell
Install-Module Pester -RequiredVersion 5.7.1 -Scope CurrentUser
Install-Module PSScriptAnalyzer -RequiredVersion 1.24.0 -Scope CurrentUser
# Windows 需指定已安裝的 v2 解譯器；請依實際安裝位置調整。
$env:REFILLING_AUTOHOTKEY_EXE = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
./Tests/Invoke-Checks.ps1
```

順序為 PowerShell 語法解析、PSScriptAnalyzer Error 級規則、Windows 的 AutoHotkey `/Validate`、Pester。安裝、登錄檔、提權與重新啟動操作均使用測試替身；AHK 路徑測試停用熱鍵，只呼叫純字串函式。Linux 明確略過 Windows 專用測試，不代表已通過 Windows 實機驗收。

GitHub Actions 包含 Windows／Linux 工作，另以真正的 Windows PowerShell 5.1 檢查第 0 階段及共用函式的語法與 UTF-8 BOM。實際安裝、登入啟動、Explorer、UAC、防火牆及重新啟動仍須在可拋棄的 Windows 11 Pro x64 VM 逐階段驗收。
