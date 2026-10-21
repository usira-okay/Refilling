BeforeAll {
    $script:CoreProjectRoot = Split-Path $PSScriptRoot -Parent
    $script:CoreScriptNames = @(
        '0 - Set ExecutionPolicy - 手動執行.ps1',
        '1 - Set System.ps1',
        '2 - Install Applications (Winget & Chocolatey).ps1',
        '3 - Install Applications (Scoop).ps1',
        '4 - nvm.ps1'
    )

    # 所有會安裝程式或變更 Windows 的命令都以測試替身隔離。
    function Invoke-ExternalCommand {
        param([string]$FilePath, [string[]]$ArgumentList, [int[]]$SuccessExitCodes = @(0))
    }
    function Test-IsAdministrator { return $false }
    function New-WinUserLanguageList { param([string]$Language) }
    function Set-WinUserLanguageList { param($LanguageList, [switch]$Force) }
    function Set-WinDefaultInputMethodOverride { param([string]$InputTip) }
    function Set-WinHomeLocation { param([int]$GeoId) }
    function Set-Culture { param([string]$CultureInfo) }
    function Get-WindowsOptionalFeature {
        [CmdletBinding()]
        param([switch]$Online, [string]$FeatureName)
    }
    function Get-AppxPackage { param([string]$Name) }
    function Add-AppxPackage { param([switch]$RegisterByFamilyName, [string]$MainPackage) }
    function Get-CimInstance { param([string]$ClassName) }
    function winget { }
    function choco { }
    function scoop { }
    function nvm { }
    function powercfg { }
    function reg { }
    function dism.exe { }
    function shutdown { }
    function Pause { }
}

Describe '核心佈建腳本' {
    BeforeEach {
        $script:CoreFixtureRoot = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        New-Item -Path $script:CoreFixtureRoot -ItemType Directory | Out-Null
        foreach ($scriptName in $script:CoreScriptNames) {
            Copy-Item -LiteralPath (Join-Path $script:CoreProjectRoot $scriptName) -Destination $script:CoreFixtureRoot
        }
        @'
param([string]$CallerPath, [switch]$SkipAdminCheck)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
return $true
'@ | Set-Content -LiteralPath (Join-Path $script:CoreFixtureRoot 'Common.ps1')
        '' | Set-Content -LiteralPath (Join-Path $script:CoreFixtureRoot 'ScriptHelpers.ps1')
        '$Config = @{ ScoopCachePath = ''C:\ScoopCache'' }' |
            Set-Content -LiteralPath (Join-Path $script:CoreFixtureRoot 'config.ps1')
        New-Item -Path (Join-Path $script:CoreFixtureRoot 'Winget Package') -ItemType Directory | Out-Null
        '{}' | Set-Content -LiteralPath (Join-Path $script:CoreFixtureRoot 'Winget Package/Tools.json')
        Push-Location -LiteralPath $script:CoreFixtureRoot

        Mock Write-Host { }
        Mock Pause { }
        Mock Read-Host { 'N' }
        Mock Set-ExecutionPolicy { }
        Mock Set-ItemProperty { }
        Mock Set-Culture { }
        Mock Set-WinUserLanguageList { }
        Mock Set-WinDefaultInputMethodOverride { }
        Mock Set-WinHomeLocation { }
        Mock New-WinUserLanguageList { ,([System.Collections.Generic.List[string]]::new()) }
        Mock Get-WindowsOptionalFeature {
            $featureNames = @(
                'Microsoft-Windows-Subsystem-Linux', 'VirtualMachinePlatform',
                'Microsoft-Hyper-V', 'Containers', 'Containers-DisposableClientVM'
            )
            foreach ($name in $featureNames) {
                if (-not $FeatureName -or $FeatureName -eq $name) {
                    [pscustomobject]@{ FeatureName = $name; State = 'Enabled' }
                }
            }
        }
        Mock Get-Command { [pscustomobject]@{ Name = $Name; Source = $Name } } -ParameterFilter {
            $Name -eq 'winget' -or $Name -eq 'choco' -or $Name -eq 'scoop' -or $Name -eq 'nvm'
        }
        Mock Get-Command { $null } -ParameterFilter { $Name -eq 'pwsh' -or $Name -eq 'pwsh.exe' }
        Mock Get-AppxPackage { $null }
        Mock Add-AppxPackage { }
        Mock Get-CimInstance {
            [pscustomobject]@{ BuildNumber = '26100'; OperatingSystemSKU = 48; ProductType = 1 }
        } -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' }
        Mock Get-CimInstance { [pscustomobject]@{ Architecture = 9 } } -ParameterFilter {
            $ClassName -eq 'Win32_Processor'
        }
        Mock Invoke-ExternalCommand { }
        Mock Test-IsAdministrator { $false }
        Mock shutdown { }
    }

    AfterEach {
        Pop-Location
    }

    It '以 WinGet 引導安裝穩定 PowerShell，且不在引導階段修改鍵盤設定' {
        & (Join-Path $script:CoreFixtureRoot $script:CoreScriptNames[0])

        Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'winget' -and $ArgumentList -contains 'Microsoft.PowerShell' -and
            $ArgumentList -contains 'winget'
        }
        Should -Invoke Set-ItemProperty -Times 0
    }

    It '註冊 App Installer 後仍找不到 WinGet 時停止引導' {
        Mock Get-Command { $null } -ParameterFilter { $Name -eq 'winget' }

        { & (Join-Path $script:CoreFixtureRoot $script:CoreScriptNames[0]) } | Should -Throw '*App Installer*'
        Should -Invoke Invoke-ExternalCommand -Times 0
    }

    It '不支援的 Windows 版本在變更執行原則與安裝前就停止' {
        Mock Get-CimInstance {
            [pscustomobject]@{ BuildNumber = '19045'; OperatingSystemSKU = 48; ProductType = 1 }
        } -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' }

        { & (Join-Path $script:CoreFixtureRoot $script:CoreScriptNames[0]) } | Should -Throw '*Windows 11 Pro x64*'
        Should -Invoke Set-ExecutionPolicy -Times 0
        Should -Invoke Invoke-ExternalCommand -Times 0
    }

    It 'Windows 功能不存在時，在改動語言及登錄前停止' {
        Mock Get-WindowsOptionalFeature {
            [pscustomobject]@{ FeatureName = 'Microsoft-Windows-Subsystem-Linux'; State = 'Enabled' }
        }

        { & (Join-Path $script:CoreFixtureRoot $script:CoreScriptNames[1]) } | Should -Throw '*VirtualMachinePlatform*'
        Should -Invoke Set-WinUserLanguageList -Times 0
        Should -Invoke Set-ItemProperty -Times 0
        Should -Invoke Invoke-ExternalCommand -Times 0
    }

    It '未明確同意時不重新啟動電腦' {
        & (Join-Path $script:CoreFixtureRoot $script:CoreScriptNames[1])

        Should -Invoke Read-Host -Times 1 -Exactly
        Should -Invoke shutdown -Times 0
        Should -Invoke Invoke-ExternalCommand -Times 0 -ParameterFilter { $FilePath -eq 'shutdown' }
    }

    It '明確回答 Y 才重新啟動，且不強制關閉應用程式' {
        Mock Read-Host { 'Y' }

        & (Join-Path $script:CoreFixtureRoot $script:CoreScriptNames[1])

        Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'shutdown' -and $ArgumentList -contains '-r' -and $ArgumentList -notcontains '-f'
        }
    }

    It 'Winget 匯入失敗時停止，不轉用 Chocolatey' {
        Mock Invoke-ExternalCommand { throw '套件匯入失敗' } -ParameterFilter {
            $FilePath -eq 'winget' -and $ArgumentList -contains 'import'
        }

        { & (Join-Path $script:CoreFixtureRoot $script:CoreScriptNames[2]) } | Should -Throw '*套件匯入失敗*'
        Should -Invoke Invoke-ExternalCommand -Times 0 -ParameterFilter { $FilePath -eq 'choco' }
    }

    It 'Chocolatey 僅安裝來源未提供的 FileZilla' {
        & (Join-Path $script:CoreFixtureRoot $script:CoreScriptNames[2])

        Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'choco' -and ($ArgumentList -join ' ') -eq 'install filezilla -y'
        }
        Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter { $FilePath -eq 'choco' }
    }

    It '管理員視窗執行 Scoop 階段時，在安裝與設定前停止' {
        Mock Test-IsAdministrator { $true }

        { & (Join-Path $script:CoreFixtureRoot $script:CoreScriptNames[3]) } | Should -Throw '*一般權限*'
        Should -Invoke Invoke-ExternalCommand -Times 0
    }

    It '從不同目錄啟動 NVM 腳本仍可載入共用啟動流程' {
        Set-Location -LiteralPath $TestDrive

        & (Join-Path $script:CoreFixtureRoot $script:CoreScriptNames[4])

        Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'nvm' -and ($ArgumentList -join ' ') -eq 'install latest'
        }
    }

    It 'Node 安裝失敗時不切換版本' {
        Mock Invoke-ExternalCommand { throw 'Node 安裝失敗' } -ParameterFilter {
            $FilePath -eq 'nvm' -and $ArgumentList -contains 'install'
        }

        { & (Join-Path $script:CoreFixtureRoot $script:CoreScriptNames[4]) } | Should -Throw '*Node 安裝失敗*'
        Should -Invoke Invoke-ExternalCommand -Times 0 -ParameterFilter {
            $FilePath -eq 'nvm' -and $ArgumentList -contains 'use'
        }
    }
}

Describe '應用程式來源與版本' {
    BeforeAll {
        $manifest = Get-Content -LiteralPath (Join-Path $script:CoreProjectRoot 'Winget Package/Tools.json') -Raw |
            ConvertFrom-Json
        $script:WingetPackages = ($manifest.Sources | Where-Object { $_.SourceDetails.Name -eq 'winget' }).Packages
        $script:StorePackages = ($manifest.Sources | Where-Object { $_.SourceDetails.Name -eq 'msstore' }).Packages
    }

    It '透過 Winget 提供 FFmpeg，且不重複安裝引導階段的 PowerShell' {
        $script:WingetPackages.PackageIdentifier | Should -Contain 'Gyan.FFmpeg'
        $script:WingetPackages.PackageIdentifier | Should -Not -Contain 'Microsoft.PowerShell'
    }

    It 'AutoHotkey 固定使用已驗證的穩定 v2' {
        $package = $script:WingetPackages | Where-Object { $_.PackageIdentifier -eq 'AutoHotkey.AutoHotkey' }
        $package.Version | Should -Be '2.0.30'
    }

    It 'LINE 使用已查證的 Microsoft Store 桌面版' {
        $script:StorePackages.PackageIdentifier | Should -Contain 'XPFCC4CD725961'
    }
}
