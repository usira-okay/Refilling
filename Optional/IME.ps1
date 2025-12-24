Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. ..\Test-Admin.ps1 -p $PSCommandPath

Write-Host '變更系統輸入法'

# 需要先安裝好華碩輸入法，並且有打開執行過

$langList = Get-WinUserLanguageList
$lang = $langList | Where-Object LanguageTag -eq "zh-Hant-TW"

# 查看該語言的輸入方式
$lang.InputMethodTips

# 新增特定輸入法（華碩輸入法）
$lang.InputMethodTips.Add("0404:{D9012138-88BF-46F4-B599-E69D8BA2FED6}{2939307A-285F-47F9-B909-8089DF8A7FDD}")
# 移除特定輸入法（微軟注音輸入法）
$lang.InputMethodTips.Remove("0404:{B115690A-EA02-48D5-A231-E3578D2FDF80}{B2F9C502-1742-11D4-9790-0080C882687E}")

Set-WinUserLanguageList $langList -Force

Pause