#requires -Version 7.0
$projectRoot = Split-Path -LiteralPath $PSScriptRoot
if (-not (. (Join-Path $projectRoot 'Common.ps1') -CallerPath $PSCommandPath)) { return }

Write-Host '設定游標'

$dirName = 'Numix Dark'
$path = Join-Path $projectRoot "Cursors/$dirName"

if (-not (Test-Path -LiteralPath $path -PathType Container)) {
    throw "找不到游標來源目錄：$path"
}

$cursors = Join-Path $env:SystemRoot "Cursors/$dirName"

if (-not (Test-Path -LiteralPath $cursors -PathType Container)) {
    Copy-Item -LiteralPath $path -Destination $cursors -Recurse
}

# 直接設定本機使用者登錄，避免依賴 Remote Registry 服務。
$cursorKey = 'HKCU:\Control Panel\Cursors'
Set-Item -LiteralPath $cursorKey -Value $cursors
$cursorFiles = @{
    AppStarting = 'AppStarting.ani'
    Arrow = 'Arrow.cur'
    Crosshair = 'Cross.cur'
    Hand = 'Hand.cur'
    Help = 'Help.cur'
    IBeam = 'IBeam.cur'
    No = 'NO.cur'
    NWPen = 'Handwriting.cur'
    SizeAll = 'SizeAll.cur'
    SizeNESW = 'SizeNESW.cur'
    SizeNS = 'SizeNS.cur'
    SizeNWSE = 'SizeNWSE.cur'
    SizeWE = 'SizeWE.cur'
    UpArrow = 'UpArrow.cur'
    Wait = 'Wait.ani'
}
foreach ($cursor in $cursorFiles.GetEnumerator()) {
    Set-ItemProperty -LiteralPath $cursorKey -Name $cursor.Key -Value (Join-Path $cursors $cursor.Value)
}

$CSharpSig = @"
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo", SetLastError = true)]
public static extern bool SystemParametersInfo(uint uiAction,uint uiParam,uint pvParam,uint fWinIni);
"@

$CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo -PassThru
$refreshCursorsAction = 0x0057
if (-not $CursorRefresh::SystemParametersInfo($refreshCursorsAction, 0, $null, 0)) {
    throw "重新載入游標失敗（Windows 錯誤碼 $([Runtime.InteropServices.Marshal]::GetLastWin32Error())）。"
}

Pause
