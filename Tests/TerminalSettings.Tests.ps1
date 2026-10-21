BeforeAll {
    . (Join-Path $PSScriptRoot '../TerminalSettings.ps1')
}

Describe 'Update-RefillingTerminalSettings' {
    It '為空設定建立 PowerShell 與 agent-dev，並將 PowerShell 設為預設' {
        $result = Update-RefillingTerminalSettings -Settings @{} -ProfilePath 'C:\Users\測試\Microsoft.PowerShell_profile.ps1'

        $result | Should -BeOfType [hashtable]
        $result.profiles.list.Count | Should -Be 2
        $result.profiles.list[0].name | Should -BeExactly 'PowerShell'
        $result.profiles.list[1].name | Should -BeExactly 'agent-dev'
        $result.profiles.list[1].guid | Should -BeExactly '{bf89599a-06b4-4ee5-bf49-72e4fb5c0eab}'
        $result.defaultProfile | Should -Be $result.profiles.list[0].guid
        $result.profiles.list[0].font.face | Should -BeExactly 'Maple Mono NF CN'
        $result.profiles.list[1].font.face | Should -BeExactly 'Maple Mono NF CN'
    }

    It '補齊缺少的清單與字型設定：<Case>' -TestCases @(
        @{ Case = '缺少 list'; Settings = @{ profiles = @{} } }
        @{ Case = '空 list'; Settings = @{ profiles = @{ list = @() } } }
        @{ Case = '缺少 font'; Settings = @{ profiles = @{ list = @(@{ name = 'PowerShell' }) } } }
        @{ Case = '缺少 font.face'; Settings = @{ profiles = @{ list = @(@{ name = 'PowerShell'; font = @{ size = 14 } }) } } }
    ) {
        param($Case, $Settings)

        $result = Update-RefillingTerminalSettings -Settings $Settings -ProfilePath 'C:\Users\User\Microsoft.PowerShell_profile.ps1'

        $result.profiles.list.Count | Should -Be 2
        $result.profiles.list[0].font.face | Should -BeExactly 'Maple Mono NF CN'
        $result.defaultProfile | Should -Not -BeNullOrEmpty
        if ($Case -eq '缺少 font.face') {
            $result.profiles.list[0].font.size | Should -Be 14
        }
    }

    It '優先選擇 PowerShell Core 來源，保留其他設定及原有順序，且不改寫輸入' {
        $legacy = @{ name = 'Windows PowerShell'; guid = '{739a6598-88a7-4fb6-b93b-ed6edb4a3b18}'; commandline = 'powershell.exe -NoLogo'; font = @{ face = 'Consolas' } }
        $named = @{ name = 'PowerShell'; guid = '{0a351213-0f7d-4f48-8fe2-8b72d2fb4c3b}'; commandline = 'pwsh -NoLogo' }
        $core = @{ name = '我的 PowerShell'; source = 'Windows.Terminal.PowershellCore'; guid = '{073af3ad-41a6-4686-8aab-98003876b5d9}'; font = @{ size = 16 }; opacity = 90 }
        $agent = @{ name = 'agent-dev'; guid = '{bf89599a-06b4-4ee5-bf49-72e4fb5c0eab}'; commandline = 'old command'; colorScheme = 'One Half Dark'; font = @{ size = 15 }; startingDirectory = 'D:\Work' }
        $settings = @{ theme = 'dark'; actions = @(@{ command = 'paste'; keys = 'ctrl+v' }); profiles = @{ defaults = @{ cursorShape = 'bar' }; list = @($legacy, $named, $agent, $core) } }
        $before = $settings | ConvertTo-Json -Depth 20 -Compress

        $result = Update-RefillingTerminalSettings -Settings $settings -ProfilePath 'C:\Users\User\Microsoft.PowerShell_profile.ps1'

        $result.profiles.list.Count | Should -Be 4
        $result.profiles.list[0].guid | Should -Be $core.guid
        $result.profiles.list[0].name | Should -BeExactly '我的 PowerShell'
        $result.profiles.list[0].opacity | Should -Be 90
        $result.profiles.list[0].font.size | Should -Be 16
        $result.profiles.list[1].guid | Should -Be $agent.guid
        $result.profiles.list[1].commandline | Should -Match '^pwsh -NoExit -EncodedCommand '
        $result.profiles.list[1].colorScheme | Should -BeExactly 'One Half Dark'
        $result.profiles.list[1].startingDirectory | Should -BeExactly 'D:\Work'
        $result.profiles.list[1].font.size | Should -Be 15
        $result.profiles.list[2].commandline | Should -BeExactly 'powershell.exe -NoLogo'
        $result.profiles.list[2].font.face | Should -BeExactly 'Consolas'
        $result.profiles.list[3].guid | Should -Be $named.guid
        $result.theme | Should -BeExactly 'dark'
        $result.actions[0].keys | Should -BeExactly 'ctrl+v'
        $result.profiles.defaults.cursorShape | Should -BeExactly 'bar'
        $result.defaultProfile | Should -Be $core.guid
        ($settings | ConvertTo-Json -Depth 20 -Compress) | Should -BeExactly $before
    }

    It '可接受有序字典並保留既有同名 profile 的自訂 GUID' {
        $settings = [ordered]@{
            profiles = [ordered]@{
                list = @(
                    [ordered]@{ name = 'agent-dev'; guid = '{7baa6d0b-ecdf-4fe0-bdbd-2cdc96d4b7a4}' }
                    [ordered]@{ name = 'PowerShell'; guid = '{2675fc19-2cae-488a-b872-c899fe2d8641}'; font = [ordered]@{ size = 13 } }
                )
            }
        }

        $result = Update-RefillingTerminalSettings -Settings $settings -ProfilePath 'C:\Users\User\Microsoft.PowerShell_profile.ps1'

        $result | Should -BeOfType [hashtable]
        $result.profiles.list[0].guid | Should -BeExactly '{2675fc19-2cae-488a-b872-c899fe2d8641}'
        $result.profiles.list[1].guid | Should -BeExactly '{7baa6d0b-ecdf-4fe0-bdbd-2cdc96d4b7a4}'
        $result.profiles.list[0].font.size | Should -Be 13
    }

    It '再次執行不重複新增 profile，並維持相同啟動設定' {
        $profilePath = 'C:\Users\User\Microsoft.PowerShell_profile.ps1'
        $first = Update-RefillingTerminalSettings -Settings @{} -ProfilePath $profilePath

        $second = Update-RefillingTerminalSettings -Settings $first -ProfilePath $profilePath

        $second.profiles.list.Count | Should -Be 2
        $second.defaultProfile | Should -BeExactly $first.defaultProfile
        foreach ($index in 0, 1) {
            $second.profiles.list[$index].guid | Should -BeExactly $first.profiles.list[$index].guid
            $second.profiles.list[$index].name | Should -BeExactly $first.profiles.list[$index].name
            $second.profiles.list[$index].commandline | Should -BeExactly $first.profiles.list[$index].commandline
            $second.profiles.list[$index].font.face | Should -BeExactly $first.profiles.list[$index].font.face
        }
    }

    It '將特殊路徑完整保留為字串且不變成額外指令：<Case>' -TestCases @(
        @{ Case = '空白與繁中'; ProfilePath = 'C:\Users\測試 User\Microsoft.PowerShell_profile.ps1' }
        @{ Case = '單引號與中括號'; ProfilePath = "C:\Users\O'Brien\[work]\Microsoft.PowerShell_profile.ps1" }
        @{ Case = '彎單引號'; ProfilePath = "C:\Users\O‘Brien’O‚Brien‛\Microsoft.PowerShell_profile.ps1" }
        @{ Case = '可被誤認為指令的字元'; ProfilePath = 'C:\Users\test''; Write-Error injected; ''$(Get-Date)&\Microsoft.PowerShell_profile.ps1' }
        @{ Case = 'UNC'; ProfilePath = '\\server\Share Folder\Microsoft.PowerShell_profile.ps1' }
    ) {
        param($Case, $ProfilePath)

        $result = Update-RefillingTerminalSettings -Settings @{} -ProfilePath $ProfilePath

        foreach ($index in 0, 1) {
            $commandLine = $result.profiles.list[$index].commandline
            $commandLine | Should -Match '^pwsh -NoExit -EncodedCommand ([A-Za-z0-9+/]+=*)$'
            $encoded = $commandLine.Substring('pwsh -NoExit -EncodedCommand '.Length)
            $command = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($encoded))
            $parseErrors = $null
            $tokens = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($command, [ref]$tokens, [ref]$parseErrors)
            $parseErrors.Count | Should -Be 0
            $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
            $commands.Count | Should -Be ($index + 1)
            $commands[0].InvocationOperator | Should -Be ([System.Management.Automation.Language.TokenKind]::Dot)
            $commands[0].CommandElements[0].Value | Should -BeExactly $ProfilePath
            if ($index -eq 1) {
                $commands[1].GetCommandName() | Should -BeExactly 'de'
                $commands[1].CommandElements[1].Value | Should -BeExactly 'agent-dev'
                $command | Should -Match ' && de agent-dev$'
            }
        }
    }

    It '對不正確的結構回報明確錯誤：<Case>' -TestCases @(
        @{ Case = '根節點'; Settings = 'invalid'; Message = '*設定根節點*物件*' }
        @{ Case = 'profiles'; Settings = @{ profiles = @() }; Message = '*profiles*物件*' }
        @{ Case = 'profiles 為 null'; Settings = @{ profiles = $null }; Message = '*profiles*物件*' }
        @{ Case = 'list'; Settings = @{ profiles = @{ list = @{} } }; Message = '*profiles.list*陣列*' }
        @{ Case = 'list 為 null'; Settings = @{ profiles = @{ list = $null } }; Message = '*profiles.list*陣列*' }
        @{ Case = 'profile'; Settings = @{ profiles = @{ list = @('invalid') } }; Message = '*profile*物件*' }
        @{ Case = 'font'; Settings = @{ profiles = @{ list = @(@{ name = 'PowerShell'; font = 'invalid' }) } }; Message = '*font*物件*' }
        @{ Case = 'font 為 null'; Settings = @{ profiles = @{ list = @(@{ name = 'PowerShell'; font = $null }) } }; Message = '*font*物件*' }
    ) {
        param($Case, $Settings, $Message)

        { Update-RefillingTerminalSettings -Settings $Settings -ProfilePath 'C:\Users\User\Microsoft.PowerShell_profile.ps1' } | Should -Throw -ExpectedMessage $Message
    }
}
