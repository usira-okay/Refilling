BeforeAll {
    $autoHotkeyScript = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../AutoHotKey/autohotkey.ahk'))
    $autoHotkeySource = Get-Content -LiteralPath $autoHotkeyScript -Raw
}

Describe 'AutoHotkey v2 快捷鍵' {
    It '明確宣告 v2，讓登入啟動時選用正確解譯器' {
        $autoHotkeySource | Should -Match '(?m)^#Requires\s+AutoHotkey\s+v2(?:\.0)?(?:\s|$)'
    }

    It '保留全部八個既有快捷鍵且不重複註冊' {
        $hotkeys = @([regex]::Matches($autoHotkeySource, '(?m)^\s*([#!^+]+[A-Za-z]+)::') | ForEach-Object { $_.Groups[1].Value.ToLowerInvariant() })
        $expected = @('^#!a', '^#!r', '^#!s', '#!p', '#!x', '#!c', '#!space', '#!v')

        $hotkeys.Count | Should -Be $expected.Count
        ($hotkeys | Sort-Object) -join ',' | Should -BeExactly (($expected | Sort-Object) -join ',')
    }

    It 'Windows：路徑只會成為 PowerShell 字串，不會被解讀為指令：<Case>' -Skip:(-not $IsWindows -or -not $env:REFILLING_AUTOHOTKEY_EXE) -TestCases @(
        @{ Case = '空白與繁中'; Path = 'C:\Users\測試 User\Documents' }
        @{ Case = '單引號與中括號'; Path = "C:\Users\O'Brien\[work]" }
        @{ Case = '彎單引號'; Path = "C:\Users\O‘Brien’O‚Brien‛" }
        @{ Case = '指令字元'; Path = 'C:\Users\test''; Write-Error injected; ''$(Get-Date)&' }
        @{ Case = 'UNC'; Path = '\\server\Share Folder' }
    ) {
        param($Case, $Path)

        $fixturePath = Join-Path $TestDrive 'quote-path.ahk'
        $inputPath = Join-Path $TestDrive 'path.txt'
        $outputPath = Join-Path $TestDrive 'quoted-path.txt'
        $utf8 = [System.Text.UTF8Encoding]::new($false)
        [System.IO.File]::WriteAllText($inputPath, $Path, $utf8)
        if (Test-Path -LiteralPath $outputPath) { Remove-Item -LiteralPath $outputPath }
        # 停用所有快捷鍵，只呼叫無系統副作用的字串轉換函式。
        $fixture = @"
#Requires AutoHotkey v2.0
#HotIf false
#Include "$autoHotkeyScript"
FileAppend QuotePowerShellLiteral(FileRead(A_Args[1], "UTF-8")), A_Args[2], "UTF-8"
ExitApp
"@
        [System.IO.File]::WriteAllText($fixturePath, $fixture, $utf8)
        $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = $env:REFILLING_AUTOHOTKEY_EXE
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true
        $startInfo.RedirectStandardError = $true
        foreach ($argument in @('/ErrorStdOut=UTF-8', $fixturePath, $inputPath, $outputPath)) {
            $startInfo.ArgumentList.Add($argument)
        }
        $process = [System.Diagnostics.Process]::Start($startInfo)
        try {
            $timeoutMilliseconds = 10000
            if (-not $process.WaitForExit($timeoutMilliseconds)) {
                $process.Kill($true)
                throw 'AutoHotkey 純字串測試逾時，已停止測試程序。'
            }
            $process.ExitCode | Should -Be 0 -Because $process.StandardError.ReadToEnd()
        } finally {
            $process.Dispose()
        }

        $literal = Get-Content -LiteralPath $outputPath -Raw
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput("Set-Location -LiteralPath $literal", [ref]$tokens, [ref]$parseErrors)
        $parseErrors.Count | Should -Be 0
        $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
        $commands.Count | Should -Be 1
        $commands[0].CommandElements[2].Value | Should -BeExactly $Path
    }
}
