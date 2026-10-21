#requires -Version 7.0
$projectRoot = Split-Path -LiteralPath $PSScriptRoot
if (-not (. (Join-Path $projectRoot 'Common.ps1') -CallerPath $PSCommandPath)) { return }

Set-StrictMode -Version Latest

# ── 已知的微軟新注音 TIP ID ──
$msNewPhoneticTips = @(
    # Microsoft Bopomofo (新注音) - Windows 10/11
    '0404:{B115690A-EA02-48D5-A231-E3578D2FDF80}{B2F9C502-1742-11D4-9790-0080C882687E}'
    # 舊版 Microsoft New Phonetic
    '0404:{531FDEBF-9B4C-4A43-A2AA-960E8FCDC732}{B2F9C502-1742-11D4-9790-0080C882687E}'
    '0404:{531FDEBF-9B4C-4A43-A2AA-960E8FCDC732}{6024B45F-5C54-11D4-B921-0080C882687E}'
)

# ── 步驟 1：掃描登錄尋找華碩注音輸入法 ──
Write-Host "`n正在搜尋已安裝的華碩注音輸入法..." -ForegroundColor Cyan

$tipBasePath = 'HKLM:\SOFTWARE\Microsoft\CTF\TIP'
$asusTipId = $null
$asusDescription = ''

function Test-AsusKeyword ([string]$text) {
    <# .SYNOPSIS 判斷輸入法描述或 DLL 路徑是否包含華碩名稱。 #>
    return ($text -match 'ASUS|華碩|asus')
}

if (Test-Path -LiteralPath $tipBasePath) {
    foreach ($tipKey in (Get-ChildItem -LiteralPath $tipBasePath)) {
        $clsid = $tipKey.PSChildName
        $langProfilePath = Join-Path $tipKey.PSPath 'LanguageProfile\0x00000404'

        if (-not (Test-Path -LiteralPath $langProfilePath)) { continue }

        foreach ($profile in (Get-ChildItem -LiteralPath $langProfilePath)) {
            $profileGuid = $profile.PSChildName
            $props = Get-ItemProperty -LiteralPath $profile.PSPath
            $descriptionProperty = $props.PSObject.Properties['Description']
            $desc = if ($descriptionProperty) { [string]$descriptionProperty.Value } else { '' }

            $isAsus = $false

            # 方法 1: 描述欄位包含 ASUS / 華碩
            if (Test-AsusKeyword $desc) {
                $isAsus = $true
            }

            # 方法 2：描述是資源字串時，檢查 DLL 路徑。
            if (-not $isAsus -and $desc -match '^@(.+\.[Dd][Ll][Ll])') {
                if (Test-AsusKeyword $Matches[1]) { $isAsus = $true }
            }

            # 方法 3: 檢查 CLSID 的 InProcServer32 DLL 路徑
            if (-not $isAsus) {
                foreach ($regRoot in @(
                    "HKLM:\SOFTWARE\Classes\CLSID\$clsid\InProcServer32",
                    "HKLM:\SOFTWARE\WOW6432Node\Classes\CLSID\$clsid\InProcServer32"
                )) {
                    if (Test-Path -LiteralPath $regRoot) {
                        $dllProperty = (Get-ItemProperty -LiteralPath $regRoot).PSObject.Properties['(default)']
                        $dllDefault = if ($dllProperty) { [string]$dllProperty.Value } else { '' }
                        if ($dllDefault -and (Test-AsusKeyword $dllDefault)) {
                            $isAsus = $true
                            break
                        }
                    }
                }
            }

            if ($isAsus) {
                $asusTipId = "0404:$clsid$profileGuid"
                $asusDescription = $desc
                break
            }
        }

        if ($asusTipId) { break }
    }
}

if (-not $asusTipId) {
    throw '找不到華碩注音輸入法，請先完成第 2 階段安裝，或至 https://www.asus.com/tw/supportonly/asus%20smart%20input/helpdesk_download/ 下載。'
}

Write-Host "找到華碩注音輸入法" -ForegroundColor Green
Write-Host "   描述 : $asusDescription" -ForegroundColor Gray
Write-Host "   TIP  : $asusTipId" -ForegroundColor Gray

# ── 步驟 2：列出目前輸入法設定 ──
Write-Host "`n目前語言設定：" -ForegroundColor Cyan

$langList = Get-WinUserLanguageList
$zhTwLang = $null

foreach ($lang in $langList) {
    Write-Host "   語言: $($lang.LanguageTag)" -ForegroundColor White
    foreach ($tip in $lang.InputMethodTips) {
        $marker = ''
        if ($msNewPhoneticTips -contains $tip) { $marker = ' ← 微軟新注音 (將移除)' }
        if ($tip -eq $asusTipId)               { $marker = ' ← 華碩注音 (已存在)' }
        Write-Host "     - $tip$marker" -ForegroundColor Gray
    }
    if ($lang.LanguageTag -match '^zh-(TW|Hant)') {
        $zhTwLang = $lang
    }
}

if (-not $zhTwLang) {
    throw '未找到繁體中文 (zh-TW) 語言設定，請先完成第 1 階段，或在 Windows 語言設定新增「中文 (繁體，台灣)」。'
}

# ── 步驟 3：移除微軟新注音、加入華碩注音 ──
$changed = $false

# 移除所有微軟新注音變體
foreach ($msTip in $msNewPhoneticTips) {
    if ($zhTwLang.InputMethodTips.Contains($msTip)) {
        $zhTwLang.InputMethodTips.Remove($msTip) | Out-Null
        Write-Host "`n移除微軟新注音: $msTip" -ForegroundColor Yellow
        $changed = $true
    }
}

# 加入華碩注音
if (-not $zhTwLang.InputMethodTips.Contains($asusTipId)) {
    $zhTwLang.InputMethodTips.Insert(0, $asusTipId)  # 插入第一個位置
    Write-Host "加入華碩注音: $asusTipId" -ForegroundColor Green
    $changed = $true
} else {
    Write-Host "`n華碩注音已在輸入法清單中。" -ForegroundColor Cyan
}

if (-not $changed) {
    Write-Host "`n不需要任何變更，目前設定已正確。" -ForegroundColor Green
    return
}

# ── 步驟 4：套用變更 ──
Write-Host "`n正在套用設定..." -ForegroundColor Cyan
Set-WinUserLanguageList $langList -Force
Write-Host "設定完成！華碩注音已取代微軟新注音。" -ForegroundColor Green
Write-Host "   若切換無效，請登出再登入或重新啟動電腦。" -ForegroundColor Gray

# ── 步驟 5：顯示最終狀態 ──
Write-Host "`n最終輸入法清單：" -ForegroundColor Cyan
$finalList = Get-WinUserLanguageList
foreach ($lang in $finalList) {
    if ($lang.LanguageTag -match '^zh-(TW|Hant)') {
        foreach ($tip in $lang.InputMethodTips) {
            $label = if ($tip -eq $asusTipId) { '華碩注音' } else { $tip }
            Write-Host "   - $label" -ForegroundColor White
        }
    }
}

Write-Host ''

Pause
