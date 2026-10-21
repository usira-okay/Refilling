BeforeAll {
    $script:DesktopProjectRoot = Split-Path $PSScriptRoot -Parent
    function Invoke-ExternalCommand { param([string]$FilePath, [string[]]$ArgumentList) }
    function reg { }
    function Pause { }
    function Get-WinUserLanguageList { }
    function Set-WinUserLanguageList { param($LanguageList, [switch]$Force) }

    # 只模擬游標重新載入的回傳值，不載入或呼叫 Windows API。
    class RefillingCursorApiStub {
        static [bool] $RefreshResult = $true
        static [bool] SystemParametersInfo([uint32]$Action, [uint32]$Parameter, [uint32]$Value, [uint32]$Flags) {
            return [RefillingCursorApiStub]::RefreshResult
        }
    }
}

Describe '選用桌面設定的錯誤處理' {
    BeforeEach {
        $script:DesktopOriginalSystemRoot = $env:SystemRoot
        $script:DesktopFixtureRoot = (New-Item -Path $TestDrive -Name ('桌面 設定[01] ' + [guid]::NewGuid().ToString('N')) -ItemType Directory).FullName
        $optionalPath = Join-Path $script:DesktopFixtureRoot 'Optional'
        New-Item -Path $optionalPath -ItemType Directory | Out-Null
        foreach ($name in @('Change Cursors.ps1', 'Windows Button.ps1', 'set-asus-ime.ps1')) {
            Copy-Item -LiteralPath (Join-Path $script:DesktopProjectRoot "Optional/$name") -Destination $optionalPath
        }
        @'
param([string]$CallerPath, [switch]$SkipAdminCheck)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -LiteralPath $CallerPath)
return $true
'@ | Set-Content -LiteralPath (Join-Path $script:DesktopFixtureRoot 'Common.ps1')

        $cursorSource = Join-Path $script:DesktopFixtureRoot 'Cursors/Numix Dark'
        [System.IO.Directory]::CreateDirectory($cursorSource) | Out-Null
        foreach ($name in @('AppStarting.ani', 'Arrow.cur', 'Cross.cur', 'Hand.cur', 'Help.cur', 'IBeam.cur', 'NO.cur', 'Handwriting.cur', 'SizeAll.cur', 'SizeNESW.cur', 'SizeNS.cur', 'SizeNWSE.cur', 'SizeWE.cur', 'UpArrow.cur', 'Wait.ani')) {
            '' | Set-Content -LiteralPath (Join-Path $cursorSource $name)
        }
        $env:SystemRoot = Join-Path $script:DesktopFixtureRoot 'Windows'
        [System.IO.Directory]::CreateDirectory((Join-Path $env:SystemRoot 'Cursors')) | Out-Null
        [RefillingCursorApiStub]::RefreshResult = $true
        Mock Add-Type { [RefillingCursorApiStub] }
        Mock Set-Item { }
        Mock Set-ItemProperty { }
        Mock Write-Host { }
        Mock Pause { }
        Mock Invoke-ExternalCommand { }
        Push-Location -LiteralPath $optionalPath
    }

    AfterEach {
        Pop-Location
        $env:SystemRoot = $script:DesktopOriginalSystemRoot
    }

    It '游標使用本機登錄提供者並支援含中括號的來源目錄' {
        $path = Join-Path $script:DesktopFixtureRoot 'Optional/Change Cursors.ps1'
        # 先阻擋舊版遠端 API，確保任何平台的測試都不接觸真實登錄。
        Get-Content -LiteralPath $path -Raw | Should -Not -Match 'OpenRemoteBaseKey'

        & $path

        Test-Path -LiteralPath (Join-Path $env:SystemRoot 'Cursors/Numix Dark/Arrow.cur') | Should -BeTrue
        Should -Invoke Set-Item -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq 'HKCU:\Control Panel\Cursors' }
        Should -Invoke Set-ItemProperty -Times 15 -Exactly -ParameterFilter { $LiteralPath -eq 'HKCU:\Control Panel\Cursors' }
        Should -Invoke Set-ItemProperty -Times 1 -Exactly -ParameterFilter {
            $Name -eq 'Arrow' -and $Value -eq (Join-Path $env:SystemRoot 'Cursors/Numix Dark/Arrow.cur')
        }
    }

    It '游標刷新失敗時不回報設定完成' {
        $path = Join-Path $script:DesktopFixtureRoot 'Optional/Change Cursors.ps1'
        Get-Content -LiteralPath $path -Raw | Should -Not -Match 'OpenRemoteBaseKey'
        [RefillingCursorApiStub]::RefreshResult = $false

        { & $path } | Should -Throw '*游標*'
    }

    It '第一個按鈕登錄設定失敗時停止，不繼續下一項' {
        Mock Invoke-ExternalCommand { throw '登錄設定失敗' }

        { & (Join-Path $script:DesktopFixtureRoot 'Optional/Windows Button.ps1') } | Should -Throw '*登錄設定失敗*'

        Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly
    }
}

Describe '華碩輸入法掃描' {
    BeforeEach {
        $script:AsusFixtureRoot = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        $optionalPath = Join-Path $script:AsusFixtureRoot 'Optional'
        New-Item -Path $optionalPath -ItemType Directory -Force | Out-Null
        $script:AsusScriptPath = Join-Path $optionalPath 'set-asus-ime.ps1'
        Copy-Item -LiteralPath (Join-Path $script:DesktopProjectRoot 'Optional/set-asus-ime.ps1') -Destination $script:AsusScriptPath
        @'
param([string]$CallerPath, [switch]$SkipAdminCheck)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -LiteralPath $CallerPath)
return $true
'@ | Set-Content -LiteralPath (Join-Path $script:AsusFixtureRoot 'Common.ps1')
        $inputTips = [System.Collections.Generic.List[string]]::new()
        $inputTips.Add('0404:{B115690A-EA02-48D5-A231-E3578D2FDF80}{B2F9C502-1742-11D4-9790-0080C882687E}')
        $global:RefillingAsusTestLanguageList = @([pscustomobject]@{ LanguageTag = 'zh-TW'; InputMethodTips = $inputTips })
        Mock Write-Host { }
        Mock Pause { }
        Mock Join-Path { "$Path\$ChildPath" } -ParameterFilter { $Path -like 'HKLM:*' }
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -like 'HKLM:*' -or $Path -like 'HKLM:*' }
        Mock Get-ChildItem {
            $registryPath = if ($LiteralPath) { $LiteralPath } else { $Path }
            if ($registryPath -eq 'HKLM:\SOFTWARE\Microsoft\CTF\TIP') {
                [pscustomobject]@{ PSChildName = '{other}'; PSPath = 'HKLM:\SOFTWARE\Microsoft\CTF\TIP\{other}' }
                [pscustomobject]@{ PSChildName = '{asus}'; PSPath = 'HKLM:\SOFTWARE\Microsoft\CTF\TIP\{asus}' }
            } elseif ($registryPath -like '*{other}*') {
                [pscustomobject]@{ PSChildName = '{other-profile}'; PSPath = 'HKLM:\SOFTWARE\Microsoft\CTF\TIP\{other}\{other-profile}' }
            } elseif ($registryPath -like '*{asus}*') {
                [pscustomobject]@{ PSChildName = '{asus-profile}'; PSPath = 'HKLM:\SOFTWARE\Microsoft\CTF\TIP\{asus}\{asus-profile}' }
            }
        } -ParameterFilter { $LiteralPath -like 'HKLM:*' -or $Path -like 'HKLM:*' }
        Mock Get-ItemProperty {
            $registryPath = if ($LiteralPath) { $LiteralPath } else { $Path }
            if ($registryPath -like '*{asus-profile}') { [pscustomobject]@{ Description = '華碩注音' } }
            else { [pscustomobject]@{ OtherValue = '缺少描述與預設 DLL 值' } }
        } -ParameterFilter { $LiteralPath -like 'HKLM:*' -or $Path -like 'HKLM:*' }
        Mock Get-WinUserLanguageList { $global:RefillingAsusTestLanguageList }
        Mock Set-WinUserLanguageList { }
        Push-Location -LiteralPath $optionalPath
    }

    AfterEach {
        Pop-Location
        Remove-Variable -Name RefillingAsusTestLanguageList -Scope Global
    }

    It '略過沒有描述與預設 DLL 值的 TIP，仍可找到並套用後續華碩輸入法' {
        & $script:AsusScriptPath

        Should -Invoke Set-WinUserLanguageList -Times 1 -Exactly -ParameterFilter {
            $LanguageList[0].InputMethodTips.Contains('0404:{asus}{asus-profile}') -and
            -not $LanguageList[0].InputMethodTips.Contains('0404:{B115690A-EA02-48D5-A231-E3578D2FDF80}{B2F9C502-1742-11D4-9790-0080C882687E}')
        }
    }

    It '未安裝華碩輸入法時拋出可診斷錯誤' {
        Mock Get-ChildItem { } -ParameterFilter { $LiteralPath -like 'HKLM:*' -or $Path -like 'HKLM:*' }

        { & $script:AsusScriptPath } | Should -Throw '*找不到華碩注音*'

        Should -Invoke Set-WinUserLanguageList -Times 0
    }
}
