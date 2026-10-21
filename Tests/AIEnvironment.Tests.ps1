BeforeAll {
    $script:AIProjectRoot = Split-Path $PSScriptRoot -Parent
    function Invoke-ExternalCommand {
        param([string]$FilePath, [string[]]$ArgumentList, [int[]]$SuccessExitCodes = @(0))
    }
    function winget { }
    function npx { }
    function Pause { }
}

Describe 'AI 環境佈建' {
    BeforeEach {
        $script:AIOriginalUserProfile = $env:USERPROFILE
        $script:AIOriginalLocalAppData = $env:LOCALAPPDATA
        $script:AIFixtureRoot = (New-Item -Path $TestDrive -Name ('AI 專案[01] ' + [guid]::NewGuid().ToString('N')) -ItemType Directory).FullName
        $optionalPath = Join-Path $script:AIFixtureRoot 'Optional'
        New-Item -Path $optionalPath -ItemType Directory | Out-Null
        $script:AIScriptPath = Join-Path $optionalPath 'Setup AI Environment.ps1'
        Copy-Item -LiteralPath (Join-Path $script:AIProjectRoot 'Optional/Setup AI Environment.ps1') -Destination $script:AIScriptPath
        @'
param([string]$CallerPath, [switch]$SkipAdminCheck)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -LiteralPath $CallerPath)
return $true
'@ | Set-Content -LiteralPath (Join-Path $script:AIFixtureRoot 'Common.ps1')
        '專案規則：保留來源及既有覆寫行為。' | Set-Content -LiteralPath (Join-Path $script:AIFixtureRoot 'AGENTS.md')
        $env:USERPROFILE = Join-Path $script:AIFixtureRoot 'user'
        $env:LOCALAPPDATA = Join-Path $env:USERPROFILE 'AppData/Local'
        $skillPath = Join-Path $env:USERPROFILE '.agents/skills/範例 [skill]'
        [System.IO.Directory]::CreateDirectory($skillPath) | Out-Null
        '測試技能' | Set-Content -LiteralPath (Join-Path $skillPath 'SKILL.md')
        $agyDirectory = Join-Path $env:LOCALAPPDATA 'agy/bin'
        [System.IO.Directory]::CreateDirectory($agyDirectory) | Out-Null
        '' | Set-Content -LiteralPath (Join-Path $agyDirectory 'agy.exe')

        # 下載替身保留實際暫存檔路徑，讓失敗案例也能驗證清理。
        $global:RefillingAITestDownloads = [System.Collections.Generic.List[string]]::new()
        Mock Write-Host { }
        Mock Pause { }
        Mock Invoke-ExternalCommand { }
        Mock Invoke-RestMethod { '# 測試安裝器，不執行安裝。' }
        Mock Invoke-WebRequest {
            '# 測試安裝器，不執行安裝。' | Set-Content -LiteralPath $OutFile
            $global:RefillingAITestDownloads.Add([string]$OutFile)
        }
        Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter { $Name -eq 'npx' -or $Name -eq 'winget' }
        Mock Get-Command { $null } -ParameterFilter {
            $Name -eq 'claude' -or $Name -eq 'codex' -or $Name -eq 'copilot' -or $Name -eq 'agy'
        }
        Push-Location -LiteralPath $optionalPath
    }

    AfterEach {
        Pop-Location
        foreach ($path in $global:RefillingAITestDownloads) {
            if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force }
        }
        Remove-Variable -Name RefillingAITestDownloads -Scope Global
        $env:USERPROFILE = $script:AIOriginalUserProfile
        $env:LOCALAPPDATA = $script:AIOriginalLocalAppData
    }

    It '缺少 npx 時在任何下載或安裝前停止' {
        Mock Get-Command { $null } -ParameterFilter { $Name -eq 'npx' }

        { & $script:AIScriptPath } | Should -Throw '*npx*'

        Should -Invoke Invoke-ExternalCommand -Times 0
        Should -Invoke Invoke-WebRequest -Times 0
        Should -Invoke Invoke-RestMethod -Times 0
    }

    It '缺少 WinGet 時在任何下載或安裝前停止' {
        Mock Get-Command { $null } -ParameterFilter { $Name -eq 'winget' }

        { & $script:AIScriptPath } | Should -Throw '*WinGet*'

        Should -Invoke Invoke-ExternalCommand -Times 0
        Should -Invoke Invoke-WebRequest -Times 0
        Should -Invoke Invoke-RestMethod -Times 0
    }

    It '缺少 AGENTS.md 時在任何下載或安裝前停止' {
        Remove-Item -LiteralPath (Join-Path $script:AIFixtureRoot 'AGENTS.md')

        { & $script:AIScriptPath } | Should -Throw '*AGENTS.md*'

        Should -Invoke Invoke-ExternalCommand -Times 0
        Should -Invoke Invoke-WebRequest -Times 0
        Should -Invoke Invoke-RestMethod -Times 0
    }

    It 'WinGet 失敗時不繼續其他 CLI 或 skills' {
        Mock Invoke-ExternalCommand { throw 'WinGet 安裝失敗' } -ParameterFilter { $FilePath -eq 'winget' }

        { & $script:AIScriptPath } | Should -Throw '*WinGet 安裝失敗*'

        Should -Invoke Invoke-WebRequest -Times 0
        Should -Invoke Invoke-ExternalCommand -Times 0 -ParameterFilter { $FilePath -eq 'npx' }
        Test-Path -LiteralPath (Join-Path $env:USERPROFILE '.copilot/copilot-instructions.md') | Should -BeFalse
    }

    It '隔離的遠端安裝器失敗時停止並清除暫存檔' {
        Mock Invoke-ExternalCommand { throw '遠端安裝器失敗' } -ParameterFilter { $ArgumentList -contains '-File' }

        { & $script:AIScriptPath } | Should -Throw '*遠端安裝器失敗*'

        $global:RefillingAITestDownloads.Count | Should -Be 1
        foreach ($path in $global:RefillingAITestDownloads) {
            Test-Path -LiteralPath $path | Should -BeFalse
        }
        Should -Invoke Invoke-ExternalCommand -Times 0 -ParameterFilter { $FilePath -eq 'npx' }
    }

    It 'skills 失敗時停止，不複製技能或覆寫指令檔' {
        Mock Invoke-ExternalCommand { throw 'skills 安裝失敗' } -ParameterFilter { $FilePath -eq 'npx' }

        { & $script:AIScriptPath } | Should -Throw '*skills 安裝失敗*'

        Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter { $FilePath -eq 'npx' }
        Test-Path -LiteralPath (Join-Path $env:USERPROFILE '.gemini/config/skills') | Should -BeFalse
        Test-Path -LiteralPath (Join-Path $env:USERPROFILE '.codex/AGENTS.md') | Should -BeFalse
    }

    It '完整成功流程保留 CLI 與 skills 來源，複製技能並覆寫四份指令檔' {
        $copilotDirectory = Join-Path $env:USERPROFILE '.copilot'
        [System.IO.Directory]::CreateDirectory($copilotDirectory) | Out-Null
        '舊規則' | Set-Content -LiteralPath (Join-Path $copilotDirectory 'copilot-instructions.md')

        & $script:AIScriptPath

        Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'winget' -and $ArgumentList -contains 'Anthropic.ClaudeCode'
        }
        Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter {
            $FilePath -eq 'winget' -and $ArgumentList -contains 'GitHub.Copilot'
        }
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter { $Uri -eq 'https://chatgpt.com/codex/install.ps1' }
        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter { $Uri -eq 'https://antigravity.google/cli/install.ps1' }
        Should -Invoke Invoke-ExternalCommand -Times 2 -Exactly -ParameterFilter {
            $FilePath -match '[\\/]pwsh(?:\.exe)?$' -and $ArgumentList -contains '-NoProfile' -and $ArgumentList -contains '-File'
        }
        Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter {
            $FilePath -like '*agy.exe' -and $ArgumentList -contains '--version'
        }
        foreach ($repo in @('github/awesome-copilot', 'dotnet/skills', 'DietrichGebert/ponytail', 'mattpocock/skills', 'usira-okay/skills')) {
            Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq 'npx' -and $ArgumentList -contains $repo -and $ArgumentList -contains '--copy'
            }
        }
        Should -Invoke Invoke-ExternalCommand -Times 5 -Exactly -ParameterFilter {
            $FilePath -eq 'npx' -and $ArgumentList -contains 'claude-code' -and
            $ArgumentList -contains 'codex' -and $ArgumentList -contains 'github-copilot'
        }
        foreach ($relativePath in @('.copilot/copilot-instructions.md', '.claude/CLAUDE.md', '.codex/AGENTS.md', '.gemini/GEMINI.md')) {
            Get-Content -LiteralPath (Join-Path $env:USERPROFILE $relativePath) -Raw |
                Should -BeExactly (Get-Content -LiteralPath (Join-Path $script:AIFixtureRoot 'AGENTS.md') -Raw)
        }
        Get-Content -LiteralPath (Join-Path $env:USERPROFILE '.gemini/config/skills/範例 [skill]/SKILL.md') |
            Should -BeExactly '測試技能'
        foreach ($path in $global:RefillingAITestDownloads) {
            Test-Path -LiteralPath $path | Should -BeFalse
        }
    }

    It '已有 CLI 時略過安裝，仍完成 skills 與指令檔同步' {
        Mock Get-Command { [pscustomobject]@{ Name = $Name } } -ParameterFilter {
            $Name -eq 'claude' -or $Name -eq 'codex' -or $Name -eq 'copilot' -or $Name -eq 'agy'
        }

        & $script:AIScriptPath

        Should -Invoke Invoke-WebRequest -Times 0
        Should -Invoke Invoke-ExternalCommand -Times 0 -ParameterFilter { $FilePath -eq 'winget' }
        Should -Invoke Invoke-ExternalCommand -Times 5 -Exactly -ParameterFilter { $FilePath -eq 'npx' }
        Test-Path -LiteralPath (Join-Path $env:USERPROFILE '.gemini/GEMINI.md') | Should -BeTrue
    }
}
