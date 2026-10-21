BeforeAll {
    . (Join-Path $PSScriptRoot '../ScriptHelpers.ps1')
    $script:PowerShellExecutable = (Get-Process -Id $PID).Path
}

Describe '外部命令執行結果' {
    It '保留成功命令的標準輸出' {
        $result = Invoke-ExternalCommand -FilePath $script:PowerShellExecutable -ArgumentList @('-NoProfile', '-Command', "Write-Output '完成'; exit 0")
        $result | Should -Be '完成'
    }

    It '非預期結束碼會終止並提供命令與代碼' {
        { Invoke-ExternalCommand -FilePath $script:PowerShellExecutable -ArgumentList @('-NoProfile', '-Command', 'exit 17') } | Should -Throw '*17*'
    }

    It '可接受工具明確定義的非零成功碼' {
        { Invoke-ExternalCommand -FilePath $script:PowerShellExecutable -ArgumentList @('-NoProfile', '-Command', 'exit 7') -SuccessExitCodes @(0, 7) } | Should -Not -Throw
    }

    It '不讓上一個命令的失敗影響下一個 PowerShell 包裝命令' {
        $global:LASTEXITCODE = 17
        function Test-NativeWrapper { '包裝成功' }
        Invoke-ExternalCommand -FilePath Test-NativeWrapper | Should -Be '包裝成功'
    }

    It 'PowerShell 包裝命令回報失敗也會終止' {
        function Test-NativeWrapper { $global:LASTEXITCODE = 23 }
        { Invoke-ExternalCommand -FilePath Test-NativeWrapper } | Should -Throw '*23*'
    }

    It '包含空白與引號的參數保持原值' {
        $fixture = Join-Path $TestDrive 'arguments.ps1'
        Set-Content -LiteralPath $fixture -Value 'param([string]$Value) Write-Output $Value'
        $value = "C:\測試 [資料]\O'Brien & tools"
        Invoke-ExternalCommand -FilePath $script:PowerShellExecutable -ArgumentList @('-NoProfile', '-File', $fixture, '-Value', $value) | Should -Be $value
    }
}

Describe 'NuGet 官方來源' {
    It '已有來源且有標題與其他來源時不重複新增' {
        Mock Invoke-ExternalCommand { @('Registered Sources:', '  1. nuget.org [Enabled]', '      https://api.nuget.org/v3/index.json', '  2. Other [Enabled]') }
        Add-RefillingNuGetSource
        Should -Invoke Invoke-ExternalCommand -Times 0 -ParameterFilter { $ArgumentList[1] -eq 'add' }
    }

    It '缺少來源時新增官方來源' {
        Mock Invoke-ExternalCommand { @('Registered Sources:', '  1. Other [Enabled]') } -ParameterFilter { $ArgumentList[1] -eq 'list' }
        Mock Invoke-ExternalCommand {} -ParameterFilter { $ArgumentList[1] -eq 'add' }
        Add-RefillingNuGetSource
        Should -Invoke Invoke-ExternalCommand -Times 1 -ParameterFilter { $ArgumentList[1] -eq 'add' -and $ArgumentList -contains 'https://api.nuget.org/v3/index.json' }
    }
}

Describe 'PowerToys 實際安裝位置' {
    BeforeEach {
        $script:OriginalLocalAppData = $env:LOCALAPPDATA
        $script:OriginalProgramFiles = $env:ProgramFiles
        $caseRoot = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        $env:LOCALAPPDATA = Join-Path $caseRoot 'user'
        $env:ProgramFiles = Join-Path $caseRoot 'machine'
    }

    AfterEach {
        $env:LOCALAPPDATA = $script:OriginalLocalAppData
        $env:ProgramFiles = $script:OriginalProgramFiles
    }

    It '解析 Winget 的電腦範圍安裝目標' {
        $directory = Join-Path $env:ProgramFiles 'PowerToys'
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
        $target = Join-Path $directory 'PowerToys.exe'
        Set-Content -LiteralPath $target -Value ''
        Get-RefillingPowerToysPath | Should -Be $target
    }

    It '目標不存在時停止，不建立無效捷徑' {
        { Get-RefillingPowerToysPath } | Should -Throw '*PowerToys*'
    }
}
