BeforeAll {
    $script:OtherSettingsRoot = Split-Path $PSScriptRoot -Parent
    $script:OtherSettingsName = '5 - Other Install And Settings.ps1'
    function Install-PackageProvider { param($Name, $Scope, [switch]$Force) }
    function Invoke-ExternalCommand { param($FilePath, $ArgumentList) }
    function Add-RefillingNuGetSource { }
    function Get-RefillingPowerToysPath { }
    function Set-RefillingTerminalSettings { param($SettingsPath, $ProfilePath) }
    function dotnet { throw '測試已隔離原生命令。' }
    function Pause { }
}

Describe '第 5 階段的前置檢查與失敗停止' {
    BeforeEach {
        $script:OtherFixture = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $script:OtherFixture | Out-Null
        Copy-Item -LiteralPath (Join-Path $script:OtherSettingsRoot $script:OtherSettingsName) -Destination $script:OtherFixture
        @'
param([string]$CallerPath, [switch]$SkipAdminCheck)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
return $true
'@ | Set-Content -LiteralPath (Join-Path $script:OtherFixture 'Common.ps1')
        '' | Set-Content -LiteralPath (Join-Path $script:OtherFixture 'TerminalSettings.ps1')
        '$Config = @{ GitName = ''測試''; GitEmail = ''test@example.com'' }' |
            Set-Content -LiteralPath (Join-Path $script:OtherFixture 'config.ps1')
        $script:SavedOtherUserProfile = $env:USERPROFILE
        $script:SavedOtherLocalAppData = $env:LOCALAPPDATA
        $env:USERPROFILE = $script:OtherFixture
        $env:LOCALAPPDATA = $script:OtherFixture
        Push-Location -LiteralPath $script:OtherFixture
        Mock Write-Host { }
        Mock Install-PackageProvider { }
        Mock Add-RefillingNuGetSource { }
        Mock Set-RefillingTerminalSettings { }
        Mock Get-RefillingPowerToysPath { Join-Path $env:USERPROFILE 'PowerToys.exe' }
        Mock Invoke-ExternalCommand { throw '安裝結束碼失敗，停止後續設定。' }
        Mock Get-Command { [pscustomobject]@{ Name = $Name; Source = $Name } } -ParameterFilter {
            $Name -in @('dotnet', 'git', 'npx', 'npm', 'oh-my-posh')
        }
    }

    AfterEach {
        Pop-Location
        $env:USERPROFILE = $script:SavedOtherUserProfile
        $env:LOCALAPPDATA = $script:SavedOtherLocalAppData
    }

    It '由其他目錄啟動也能回報缺少設定檔，而不開始安裝' {
        Remove-Item -LiteralPath (Join-Path $script:OtherFixture 'config.ps1')
        Set-Location -LiteralPath $TestDrive

        { & (Join-Path $script:OtherFixture $script:OtherSettingsName) } | Should -Throw '*找不到 config.ps1*'
        Should -Invoke Install-PackageProvider -Times 0
    }

    It '拒絕空白 Git 名稱，且不開始安裝' {
        '$Config = @{ GitName = '' ''; GitEmail = ''test@example.com'' }' |
            Set-Content -LiteralPath (Join-Path $script:OtherFixture 'config.ps1')

        { & (Join-Path $script:OtherFixture $script:OtherSettingsName) } | Should -Throw '*GitName*'
        Should -Invoke Install-PackageProvider -Times 0
    }

    It '缺少必要工具時停止，提示重開 PowerShell 視窗' {
        Mock Get-Command { $null } -ParameterFilter { $Name -eq 'dotnet' }

        { & (Join-Path $script:OtherFixture $script:OtherSettingsName) } | Should -Throw '*dotnet*PowerShell*'
        Should -Invoke Install-PackageProvider -Times 0
    }

    It 'PowerToys 尚未安裝時不產生無效捷徑' {
        Mock Get-RefillingPowerToysPath { throw '找不到 PowerToys.exe' }

        { & (Join-Path $script:OtherFixture $script:OtherSettingsName) } | Should -Throw '*找不到 PowerToys.exe*'
        Should -Invoke Install-PackageProvider -Times 0
    }

    It 'dotnet-ef 安裝失敗時立即停止，不繼續 Git 或其他原生命令' {
        { & (Join-Path $script:OtherFixture $script:OtherSettingsName) } | Should -Throw '*安裝結束碼失敗*'

        Should -Invoke Add-RefillingNuGetSource -Times 1 -Exactly
        Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'dotnet' -and ($ArgumentList -join ' ') -eq 'tool install --global dotnet-ef'
        }
        Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly
        Should -Invoke Set-RefillingTerminalSettings -Times 0
    }
}
