BeforeAll {
    $script:EntryProjectRoot = Split-Path $PSScriptRoot -Parent

    # 測試只載入空白共用函式檔，實際管理員判斷與提權程序都由替身處理。
    function Test-IsAdministrator { return $false }
}

Describe '共用入口與提權' {
    BeforeEach {
        $fixtureName = "入口 測試[01]' " + [guid]::NewGuid().ToString()
        $script:EntryFixtureRoot = (New-Item -Path $TestDrive -Name $fixtureName -ItemType Directory).FullName
        foreach ($fileName in @('Common.ps1', 'Test-Admin.ps1')) {
            Copy-Item -LiteralPath (Join-Path $script:EntryProjectRoot $fileName) -Destination $script:EntryFixtureRoot
        }
        '' | Set-Content -LiteralPath (Join-Path $script:EntryFixtureRoot 'ScriptHelpers.ps1')
        $script:EntryCallerPath = Join-Path $script:EntryFixtureRoot "1 - 系統 [腳本]'s.ps1"
        @'
if (-not (. (Join-Path $PSScriptRoot 'Common.ps1') -CallerPath $PSCommandPath)) { return }
'入口已繼續'
'@ | Set-Content -LiteralPath $script:EntryCallerPath
        $script:EntryPowerShellPath = 'C:\Program Files\PowerShell\7\pwsh.exe'

        Push-Location -LiteralPath $TestDrive
        Mock Test-IsAdministrator { $false }
        Mock Get-Process { [pscustomobject]@{ Path = 'C:\Program Files\PowerShell\7\pwsh.exe' } } -ParameterFilter { $Id -eq $PID }
        Mock Start-Process { }
    }

    AfterEach {
        Pop-Location
    }

    It '非 Windows 平台在載入權限檢查或變更目錄前停止' -Skip:$IsWindows {
        $originalLocation = (Get-Location).Path

        { . (Join-Path $script:EntryFixtureRoot 'Common.ps1') -CallerPath $script:EntryCallerPath } |
            Should -Throw '*Windows 11 Pro x64*'

        (Get-Location).Path | Should -Be $originalLocation
        Should -Invoke Test-IsAdministrator -Times 0
        Should -Invoke Start-Process -Times 0
    }

    It 'Windows 可從任意目錄載入並以 LiteralPath 切換到腳本目錄，且略過權限檢查' -Skip:(-not $IsWindows) {
        $result = . (Join-Path $script:EntryFixtureRoot 'Common.ps1') -CallerPath $script:EntryCallerPath -SkipAdminCheck

        $result | Should -BeTrue
        (Get-Location).Path | Should -Be $script:EntryFixtureRoot
        Should -Invoke Test-IsAdministrator -Times 0
        Should -Invoke Start-Process -Times 0
    }

    It 'Windows 管理員入口回傳 true 並直接繼續原腳本' -Skip:(-not $IsWindows) {
        Mock Test-IsAdministrator { $true }

        $result = & $script:EntryCallerPath

        $result | Should -Be '入口已繼續'
        (Get-Location).Path | Should -Be $script:EntryFixtureRoot
        Should -Invoke Test-IsAdministrator -Times 1 -Exactly
        Should -Invoke Start-Process -Times 0
    }

    It 'Windows 一般權限入口啟動提權程序後停止父腳本' -Skip:(-not $IsWindows) {
        $result = & $script:EntryCallerPath

        $result | Should -BeNullOrEmpty
        Should -Invoke Start-Process -Times 1 -Exactly -ParameterFilter { $Verb -eq 'RunAs' }
    }

    It '提權以目前 PowerShell 的 File 參數完整傳遞空白、繁中、單引號與中括號路徑' {
        $result = & (Join-Path $script:EntryFixtureRoot 'Test-Admin.ps1') -p $script:EntryCallerPath

        $result | Should -BeFalse
        Should -Invoke Start-Process -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq $script:EntryPowerShellPath -and $Verb -eq 'RunAs' -and
            $WorkingDirectory -eq $script:EntryFixtureRoot -and
            ($ArgumentList -join '|') -eq (@(
                '-NoLogo', '-NoProfile', '-NoExit', '-File', ('"{0}"' -f $script:EntryCallerPath)
            ) -join '|')
        }
    }

    It '已是管理員時回傳 true 且不另開程序' {
        Mock Test-IsAdministrator { $true }

        $result = & (Join-Path $script:EntryFixtureRoot 'Test-Admin.ps1') -p $script:EntryCallerPath

        $result | Should -BeTrue
        Should -Invoke Start-Process -Times 0
    }

    It '不存在的腳本路徑在管理員檢查與提權前被拒絕' {
        $missingPath = Join-Path $script:EntryFixtureRoot "不存在 [腳本]'s.ps1"

        { & (Join-Path $script:EntryFixtureRoot 'Test-Admin.ps1') -p $missingPath } | Should -Throw

        Should -Invoke Test-IsAdministrator -Times 0
        Should -Invoke Start-Process -Times 0
    }

    It '提權程序啟動失敗時保留錯誤，不回報可繼續' {
        Mock Start-Process { throw '使用者取消提權' }

        { & (Join-Path $script:EntryFixtureRoot 'Test-Admin.ps1') -p $script:EntryCallerPath } |
            Should -Throw '*使用者取消提權*'
    }
}
