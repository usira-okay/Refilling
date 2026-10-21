#Requires AutoHotkey v2.0

^#!a::Run "shutdown -a"
^#!r::Run "shutdown -r -t 10 -f"
^#!s::Run "shutdown -s -t 10 -f"

#!p::SendText "，再麻煩協助 review & merge 感謝"

#!x::
{
    profile := QuotePowerShellLiteral(GetPowerShellProfilePath())
    Run '"pwsh" -NoExit -Command ". ' profile ' && de agent-dev"'
}

#!c::
{
    path := QuotePowerShellLiteral(GetActiveExplorerPath())
    profile := QuotePowerShellLiteral(GetPowerShellProfilePath())
    Run '"pwsh" -NoExit -Command ". ' profile ' && Set-Location -LiteralPath ' path '"'
}

#!space::
{
    path := QuotePowerShellLiteral(GetActiveExplorerPath())
    profile := QuotePowerShellLiteral(GetPowerShellProfilePath())
    Run '*RunAs "pwsh" -NoExit -Command ". ' profile ' && Set-Location -LiteralPath ' path '"'
}

#!v::
{
    path := QuotePowerShellLiteral(GetActiveExplorerPath())
    Run '"pwsh" -NoProfile -WindowStyle Hidden -Command "code ' path '"', , "Hide"
}

/** 取得活動 Explorer 的實體資料夾，其他視窗或虛擬資料夾則使用桌面。 */
GetActiveExplorerPath()
{
    explorerHwnd := WinActive("ahk_class CabinetWClass")
    if explorerHwnd
    {
        for window in ComObject("Shell.Application").Windows()
        {
            if window.hwnd = explorerHwnd
            {
                folder := window.Document.Folder.Self
                if folder.IsFileSystem && DirExist(folder.Path)
                    return folder.Path
                break
            }
        }
    }
    return A_Desktop
}

/** 取得主安裝流程建立的個人 PowerShell Profile 路徑。 */
GetPowerShellProfilePath()
{
    return EnvGet("USERPROFILE") "\Microsoft.PowerShell_profile.ps1"
}

/** 將路徑轉成 PowerShell 字串字面值，避免一般及彎單引號終止字串。 */
QuotePowerShellLiteral(value)
{
    return "'" RegExReplace(value, "['‘’‚‛]", "$0$0") "'"
}
