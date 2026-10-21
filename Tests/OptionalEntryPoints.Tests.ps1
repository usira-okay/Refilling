BeforeAll {
    $script:OptionalSourceRoot = Join-Path (Split-Path $PSScriptRoot -Parent) 'Optional'
}

Describe 'Optional 的共同入口' {
    BeforeEach {
        $fixtureName = "可選腳本 [資料夾]' " + [guid]::NewGuid().ToString('N')
        $script:OptionalEntryRoot = (New-Item -ItemType Directory -Path $TestDrive -Name $fixtureName).FullName
        $script:OptionalEntryDirectory = [System.IO.Directory]::CreateDirectory((Join-Path $script:OptionalEntryRoot 'Optional')).FullName
        @'
param([string]$CallerPath, [switch]$SkipAdminCheck)
$global:RefillingTestCallerPath = $CallerPath
return $false
'@ | Set-Content -LiteralPath (Join-Path $script:OptionalEntryRoot 'Common.ps1')
        $global:RefillingTestCallerPath = $null
        Push-Location -LiteralPath $TestDrive
    }

    AfterEach {
        Pop-Location
        Remove-Variable -Name RefillingTestCallerPath -Scope Global
    }

    It '從任意目錄執行 <ScriptName>，共用入口要求停止時不繼續變更系統' -TestCases @(
        @{ ScriptName = 'Change Cursors.ps1' }
        @{ ScriptName = 'Change Remote Port.ps1' }
        @{ ScriptName = 'Set Desktop.ps1' }
        @{ ScriptName = 'Set User Password.ps1' }
        @{ ScriptName = 'Set-SSH.ps1' }
        @{ ScriptName = 'Setup AI Environment.ps1' }
        @{ ScriptName = 'Windows Button.ps1' }
        @{ ScriptName = 'set-asus-ime.ps1' }
    ) {
        param($ScriptName)
        Copy-Item -LiteralPath (Join-Path $script:OptionalSourceRoot $ScriptName) -Destination $script:OptionalEntryDirectory
        $entryPath = Join-Path $script:OptionalEntryDirectory $ScriptName

        $result = & $entryPath

        $global:RefillingTestCallerPath | Should -BeExactly $entryPath
        $result | Should -BeNullOrEmpty
    }
}
