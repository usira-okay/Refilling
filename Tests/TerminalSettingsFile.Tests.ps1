BeforeAll {
    . (Join-Path $PSScriptRoot '../TerminalSettings.ps1')
}

Describe 'Set-RefillingTerminalSettings 的檔案保存' {
    BeforeEach {
        $settingsDirectory = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        $settingsPath = Join-Path $settingsDirectory 'LocalState/settings.json'
        $profilePath = "C:\Users\O'Brien [測試]\Microsoft.PowerShell_profile.ps1"
    }

    It '首次使用時建立目錄及有效設定，寫入 UTF-8 無 BOM' {
        Set-RefillingTerminalSettings -SettingsPath $settingsPath -ProfilePath $profilePath

        $result = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json -AsHashtable
        $result.profiles.list.Count | Should -Be 2
        $result.defaultProfile | Should -Be $result.profiles.list[0].guid
        $bytes = [System.IO.File]::ReadAllBytes($settingsPath)
        [System.BitConverter]::ToString($bytes, 0, 3) | Should -Not -Be 'EF-BB-BF'
        @(Get-ChildItem -LiteralPath (Split-Path $settingsPath) -Filter '*.backup.*').Count | Should -Be 0
    }

    It '更新前保存原始檔案，並保留自訂設定' {
        $original = '{"theme":"dark","profiles":{"defaults":{"opacity":85}}}'
        New-Item -ItemType Directory -Path (Split-Path $settingsPath) -Force | Out-Null
        [System.IO.File]::WriteAllText($settingsPath, $original)

        Set-RefillingTerminalSettings -SettingsPath $settingsPath -ProfilePath $profilePath

        $backup = @(Get-ChildItem -LiteralPath (Split-Path $settingsPath) -Filter '*.backup.*')
        $backup.Count | Should -Be 1
        [System.IO.File]::ReadAllText($backup[0].FullName) | Should -BeExactly $original
        $result = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json -AsHashtable
        $result.theme | Should -BeExactly 'dark'
        $result.profiles.defaults.opacity | Should -Be 85
        @(Get-ChildItem -LiteralPath (Split-Path $settingsPath) -Filter '*.tmp').Count | Should -Be 0
    }

    It '拒絕不完整 JSON 或錯誤結構，且不改動原始檔：<Original>' -TestCases @(
        @{ Original = '{broken'; Message = '*JSON*' }
        @{ Original = '{"profiles":[]}'; Message = '*profiles*物件*' }
        @{ Original = 'null'; Message = '*設定根節點*物件*' }
        @{ Original = ''; Message = '*不可為空*' }
    ) {
        param($Original, $Message)
        New-Item -ItemType Directory -Path (Split-Path $settingsPath) -Force | Out-Null
        [System.IO.File]::WriteAllText($settingsPath, $Original)

        { Set-RefillingTerminalSettings -SettingsPath $settingsPath -ProfilePath $profilePath } | Should -Throw -ExpectedMessage $Message

        [System.IO.File]::ReadAllText($settingsPath) | Should -BeExactly $Original
        @(Get-ChildItem -LiteralPath (Split-Path $settingsPath)).Count | Should -Be 1
    }
}
