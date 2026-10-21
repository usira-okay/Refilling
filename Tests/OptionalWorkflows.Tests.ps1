BeforeAll {
    $script:OptionalWorkflowRoot = Split-Path $PSScriptRoot -Parent
    $script:OptionalWorkflowNames = @(
        'Set-SSH.ps1', 'Set User Password.ps1', 'Set Desktop.ps1', 'Change Remote Port.ps1'
    )

    # 以測試替身隔離帳號、服務、防火牆與原生命令；檔案僅寫入 TestDrive。
    function Invoke-ExternalCommand { param($FilePath, $ArgumentList) }
    function Get-Service { param($Name) }
    function Set-Service {
        param($Name, $StartupType, [Parameter(ValueFromPipeline)]$InputObject)
    }
    function Start-Service { param($Name) }
    function Get-LocalUser { param($Name) }
    function Set-LocalUser {
        param([Parameter(ValueFromPipeline)]$InputObject, $Password)
    }
    function Get-NetFirewallRule { param($Name) }
    function New-NetFirewallRule {
        param($Name, $DisplayName, $Profile, $Direction, $Action, $Protocol, $LocalPort, $Enabled)
    }
    function Set-NetFirewallRule {
        param($Name, $Profile, $Direction, $Action, $Protocol, $LocalPort, $Enabled)
    }
    function git { }
    function ssh-add { }
    function mkdir {
        param($Path, [switch]$Force)
        New-Item -ItemType Directory -Path $Path -Force:$Force | Out-Null
    }
    function Pause { }
    function New-OptionalTestPassword {
        <# .SYNOPSIS 以固定測試文字建立 SecureString，僅供隔離測試使用。 #>
        param([string]$Text)
        $secureValue = [System.Security.SecureString]::new()
        foreach ($character in $Text.ToCharArray()) {
            $secureValue.AppendChar($character)
        }
        $secureValue.MakeReadOnly()
        return $secureValue
    }
}

Describe 'Optional 個人設定流程' {
    BeforeEach {
        $script:OptionalWorkflowFixture = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        $script:OptionalWorkflowDirectory = Join-Path $script:OptionalWorkflowFixture 'Optional'
        $script:OptionalWorkflowUser = Join-Path $script:OptionalWorkflowFixture 'user'
        $script:OptionalWorkflowWindows = Join-Path $script:OptionalWorkflowFixture 'Windows'
        $script:OptionalKeySource = Join-Path $script:OptionalWorkflowUser 'source'
        $script:OptionalSshDestination = Join-Path $script:OptionalWorkflowUser '.ssh'
        $script:OptionalDesktopTarget = Join-Path $script:OptionalWorkflowUser 'desktop'
        $script:OptionalOpenSshDirectory = Join-Path $script:OptionalWorkflowWindows 'System32/OpenSSH'
        foreach ($directory in @(
            $script:OptionalWorkflowDirectory, $script:OptionalKeySource,
            $script:OptionalDesktopTarget, $script:OptionalOpenSshDirectory
        )) {
            New-Item -Path $directory -ItemType Directory -Force | Out-Null
        }
        foreach ($name in $script:OptionalWorkflowNames) {
            Copy-Item -LiteralPath (Join-Path $script:OptionalWorkflowRoot "Optional/$name") -Destination $script:OptionalWorkflowDirectory
        }
        @'
param([string]$CallerPath, [switch]$SkipAdminCheck)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -LiteralPath $CallerPath)
return $true
'@ | Set-Content -LiteralPath (Join-Path $script:OptionalWorkflowFixture 'Common.ps1')
        @'
$Config = @{
    SshKeySource = Join-Path $env:USERPROFILE 'source'
    DesktopPath = Join-Path $env:USERPROFILE 'desktop'
}
'@ | Set-Content -LiteralPath (Join-Path $script:OptionalWorkflowFixture 'config.ps1')
        foreach ($openSshToolName in @('ssh.exe', 'ssh-add.exe')) {
            '' | Set-Content -LiteralPath (Join-Path $script:OptionalOpenSshDirectory $openSshToolName)
        }
        '-----BEGIN OPENSSH PRIVATE KEY-----' |
            Set-Content -LiteralPath (Join-Path $script:OptionalKeySource 'id_ed25519')

        $script:OptionalSavedUserProfile = $env:USERPROFILE
        $script:OptionalSavedUsername = $env:USERNAME
        $script:OptionalSavedWindows = $env:WINDIR
        $env:USERPROFILE = $script:OptionalWorkflowUser
        $env:USERNAME = 'fixture-user'
        $env:WINDIR = $script:OptionalWorkflowWindows
        Push-Location -LiteralPath $script:OptionalWorkflowDirectory

        Mock Write-Host { }
        Mock Pause { }
        Mock Invoke-ExternalCommand { }
        Mock git { }
        Mock ssh-add { }
        Mock Get-Command { [pscustomobject]@{ Name = $Name; Source = $Name } } -ParameterFilter { $Name -eq 'git' }
        Mock Get-Service { [pscustomobject]@{ Name = 'ssh-agent' } }
        Mock Set-Service { }
        Mock Start-Service { }
        Mock Get-LocalUser { [pscustomobject]@{ Name = $Name } }
        Mock Set-LocalUser { }
        Mock Set-ItemProperty { }
        Mock Stop-Process { }
        Mock Start-Process { }
        Mock Get-NetFirewallRule { @() }
        Mock New-NetFirewallRule { }
        Mock Set-NetFirewallRule { }
    }

    AfterEach {
        Pop-Location
        $env:USERPROFILE = $script:OptionalSavedUserProfile
        $env:USERNAME = $script:OptionalSavedUsername
        $env:WINDIR = $script:OptionalSavedWindows
    }

    Context 'SSH 私鑰來源與失敗停止' {
        It '來源是檔案時在建立 .ssh 與變更服務前停止' {
            Remove-Item -LiteralPath $script:OptionalKeySource -Recurse
            '-----BEGIN OPENSSH PRIVATE KEY-----' | Set-Content -LiteralPath $script:OptionalKeySource

            { & (Join-Path $script:OptionalWorkflowDirectory 'Set-SSH.ps1') } | Should -Throw '*SshKeySource*資料夾*'

            Test-Path -LiteralPath $script:OptionalSshDestination | Should -BeFalse
            Should -Invoke Set-Service -Times 0
            Should -Invoke Invoke-ExternalCommand -Times 0
        }

        It '缺少必要工具 <Tool> 時不複製或變更服務' -ForEach @(
            @{ Tool = 'git' }, @{ Tool = 'ssh.exe' }, @{ Tool = 'ssh-add.exe' }
        ) {
            if ($Tool -eq 'git') {
                Mock Get-Command { $null } -ParameterFilter { $Name -eq 'git' }
            } else {
                Remove-Item -LiteralPath (Join-Path $script:OptionalOpenSshDirectory $Tool)
            }

            { & (Join-Path $script:OptionalWorkflowDirectory 'Set-SSH.ps1') } | Should -Throw "*$Tool*"

            Test-Path -LiteralPath $script:OptionalSshDestination | Should -BeFalse
            Should -Invoke Set-Service -Times 0
            Should -Invoke Invoke-ExternalCommand -Times 0
        }

        It '來源沒有可辨識私鑰時停止，而不建立空白成功結果' {
            Remove-Item -LiteralPath (Join-Path $script:OptionalKeySource 'id_ed25519')
            'ssh-ed25519 public-data' | Set-Content -LiteralPath (Join-Path $script:OptionalKeySource 'id_ed25519.pub')
            'Host example' | Set-Content -LiteralPath (Join-Path $script:OptionalKeySource 'config')

            { & (Join-Path $script:OptionalWorkflowDirectory 'Set-SSH.ps1') } | Should -Throw '*私鑰*'

            Test-Path -LiteralPath $script:OptionalSshDestination | Should -BeFalse
            Should -Invoke Start-Service -Times 0
            Should -Invoke Invoke-ExternalCommand -Times 0
        }

        It '只複製並加入來源中具有私鑰首行的檔案，保留既有本機檔案' {
            $privateKeyFiles = @{
                'id_rsa' = '-----BEGIN RSA PRIVATE KEY-----'
                'pkcs8.pem' = '-----BEGIN PRIVATE KEY-----'
                'encrypted.pem' = '-----BEGIN ENCRYPTED PRIVATE KEY-----'
                'key[personal]' = '-----BEGIN EC PRIVATE KEY-----'
            }
            foreach ($name in $privateKeyFiles.Keys) {
                $privateKeyFiles[$name] | Set-Content -LiteralPath (Join-Path $script:OptionalKeySource $name)
            }
            foreach ($name in @('config', 'known_hosts', 'authorized_keys', 'id_other.pub', 'id_other.ppk')) {
                '-----BEGIN OPENSSH PRIVATE KEY-----' | Set-Content -LiteralPath (Join-Path $script:OptionalKeySource $name)
            }
            '這是說明文件' | Set-Content -LiteralPath (Join-Path $script:OptionalKeySource 'README')
            New-Item -Path $script:OptionalSshDestination -ItemType Directory | Out-Null
            '原有設定' | Set-Content -LiteralPath (Join-Path $script:OptionalSshDestination 'config')
            '-----BEGIN OPENSSH PRIVATE KEY-----' |
                Set-Content -LiteralPath (Join-Path $script:OptionalSshDestination 'unrelated_key')

            & (Join-Path $script:OptionalWorkflowDirectory 'Set-SSH.ps1')

            $copiedNames = @(Get-ChildItem -LiteralPath $script:OptionalSshDestination -File | Select-Object -ExpandProperty Name)
            $copiedNames.Count | Should -Be 7
            foreach ($name in @('id_ed25519') + @($privateKeyFiles.Keys)) {
                $copiedNames | Should -Contain $name
                Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter {
                    $FilePath -eq (Join-Path $script:OptionalOpenSshDirectory 'ssh-add.exe') -and
                    $ArgumentList.Count -eq 1 -and $ArgumentList[0] -eq (Join-Path $script:OptionalSshDestination $name)
                }
            }
            Get-Content -LiteralPath (Join-Path $script:OptionalSshDestination 'config') | Should -Be '原有設定'
            Should -Invoke Invoke-ExternalCommand -Times 5 -Exactly -ParameterFilter {
                $FilePath -eq (Join-Path $script:OptionalOpenSshDirectory 'ssh-add.exe')
            }
        }

        It 'git 設定失敗後不繼續 ssh-add，也不顯示完成' {
            Mock Invoke-ExternalCommand { throw 'git 結束碼 1' } -ParameterFilter { $FilePath -eq 'git' }

            { & (Join-Path $script:OptionalWorkflowDirectory 'Set-SSH.ps1') } | Should -Throw '*git 結束碼 1*'

            Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly
            Should -Invoke Write-Host -Times 0 -ParameterFilter { "$Object" -match 'completed|完成|Successfully|成功加入' }
        }

        It 'ssh-add 失敗立即停止，不回報成功或處理後續私鑰' {
            '-----BEGIN RSA PRIVATE KEY-----' | Set-Content -LiteralPath (Join-Path $script:OptionalKeySource 'id_rsa')
            Mock Invoke-ExternalCommand { throw 'ssh-add 結束碼 1' } -ParameterFilter {
                $FilePath -eq (Join-Path $env:WINDIR 'System32/OpenSSH/ssh-add.exe')
            }

            { & (Join-Path $script:OptionalWorkflowDirectory 'Set-SSH.ps1') } | Should -Throw '*ssh-add 結束碼 1*'

            Should -Invoke Invoke-ExternalCommand -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq (Join-Path $script:OptionalOpenSshDirectory 'ssh-add.exe')
            }
            Should -Invoke Write-Host -Times 0 -ParameterFilter { "$Object" -match 'completed|完成|Successfully|成功加入' }
        }
    }

    Context '密碼比較與設定' {
        BeforeEach {
            $script:OptionalPasswordState = @{ Index = 0; Passwords = @() }
            $passwordState = $script:OptionalPasswordState
            Mock Read-Host -MockWith ({
                $password = $passwordState.Passwords[$passwordState.Index]
                $passwordState.Index++
                return $password
            }.GetNewClosure())
        }

        It '大小寫不同的密碼不呼叫 Set-LocalUser' {
            $script:OptionalPasswordState.Passwords = @(
                (New-OptionalTestPassword 'Abc123!'),
                (New-OptionalTestPassword 'abc123!')
            )

            { & (Join-Path $script:OptionalWorkflowDirectory 'Set User Password.ps1') } | Should -Throw '*不一致*'

            Should -Invoke Set-LocalUser -Times 0
        }

        It '嵌入 NUL 後的不同內容仍視為不一致' {
            $script:OptionalPasswordState.Passwords = @(
                (New-OptionalTestPassword "same`0one"),
                (New-OptionalTestPassword "same`0two")
            )

            { & (Join-Path $script:OptionalWorkflowDirectory 'Set User Password.ps1') } | Should -Throw '*不一致*'

            Should -Invoke Set-LocalUser -Times 0
        }

        It '字形相同但 Unicode 序列不同的密碼仍視為不一致' {
            $script:OptionalPasswordState.Passwords = @(
                (New-OptionalTestPassword "caf$([char]0xE9)"),
                (New-OptionalTestPassword "cafe$([char]0x301)")
            )

            { & (Join-Path $script:OptionalWorkflowDirectory 'Set User Password.ps1') } | Should -Throw '*不一致*'

            Should -Invoke Set-LocalUser -Times 0
        }

        It '相同 Unicode 密碼使用原本的 SecureString 更新目前帳號' {
            $script:OptionalPasswordState.Passwords = @(
                (New-OptionalTestPassword '密碼🔑大小寫AbC'),
                (New-OptionalTestPassword '密碼🔑大小寫AbC')
            )

            & (Join-Path $script:OptionalWorkflowDirectory 'Set User Password.ps1')

            Should -Invoke Get-LocalUser -Times 1 -Exactly -ParameterFilter { $Name -eq 'fixture-user' }
            Should -Invoke Set-LocalUser -Times 1 -Exactly -ParameterFilter {
                [object]::ReferenceEquals($Password, $script:OptionalPasswordState.Passwords[0])
            }
        }

        It '更新帳號失敗時向外拋錯，不顯示設定完成' {
            $script:OptionalPasswordState.Passwords = @(
                (New-OptionalTestPassword 'Abc123!'),
                (New-OptionalTestPassword 'Abc123!')
            )
            Mock Set-LocalUser { throw '帳號密碼原則拒絕更新' }

            { & (Join-Path $script:OptionalWorkflowDirectory 'Set User Password.ps1') } | Should -Throw '*帳號密碼原則拒絕更新*'

            Should -Invoke Write-Host -Times 0 -ParameterFilter { "$Object" -match '完成|成功更新' }
        }
    }

    Context '桌面路徑與 Explorer' {
        It '目標是檔案時拒絕寫登錄及重啟 Explorer' {
            Remove-Item -LiteralPath $script:OptionalDesktopTarget -Recurse
            '不是資料夾' | Set-Content -LiteralPath $script:OptionalDesktopTarget

            { & (Join-Path $script:OptionalWorkflowDirectory 'Set Desktop.ps1') } | Should -Throw '*DesktopPath*資料夾*'

            Should -Invoke Set-ItemProperty -Times 0
            Should -Invoke Stop-Process -Times 0
            Should -Invoke Start-Process -Times 0
        }

        It '含方括號的資料夾以字面路徑設定，並重啟 Explorer' {
            $script:OptionalDesktopTarget = Join-Path $script:OptionalWorkflowUser 'desktop[個人]'
            New-Item -Path $script:OptionalDesktopTarget -ItemType Directory | Out-Null
            '$Config = @{ DesktopPath = Join-Path $env:USERPROFILE ''desktop[個人]'' }' |
                Set-Content -LiteralPath (Join-Path $script:OptionalWorkflowFixture 'config.ps1')

            & (Join-Path $script:OptionalWorkflowDirectory 'Set Desktop.ps1')

            Should -Invoke Set-ItemProperty -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'Desktop' -and $Value -eq $script:OptionalDesktopTarget
            }
            Should -Invoke Stop-Process -Times 1 -Exactly -ParameterFilter { $Name -eq 'explorer' -and $Force }
            Should -Invoke Start-Process -Times 1 -Exactly -ParameterFilter { $FilePath -eq 'explorer' }
        }

        It '登錄寫入失敗保留原始錯誤，且不重啟 Explorer' {
            Mock Set-ItemProperty { throw 'fixture-registry-denied' }

            { & (Join-Path $script:OptionalWorkflowDirectory 'Set Desktop.ps1') } | Should -Throw 'fixture-registry-denied'

            Should -Invoke Stop-Process -Times 0
            Should -Invoke Start-Process -Times 0
        }

        It '存在的相對資料夾以完整檔案系統路徑寫入登錄' {
            '$Config = @{ DesktopPath = ''../user/desktop'' }' |
                Set-Content -LiteralPath (Join-Path $script:OptionalWorkflowFixture 'config.ps1')

            & (Join-Path $script:OptionalWorkflowDirectory 'Set Desktop.ps1')

            Should -Invoke Set-ItemProperty -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'Desktop' -and $Value -eq $script:OptionalDesktopTarget
            }
        }

        It '非檔案系統容器不寫入桌面登錄，也不重啟 Explorer' {
            '$Config = @{ DesktopPath = ''Registry::HKEY_CURRENT_USER'' }' |
                Set-Content -LiteralPath (Join-Path $script:OptionalWorkflowFixture 'config.ps1')
            Mock Test-Path { $true } -ParameterFilter {
                $LiteralPath -eq 'Registry::HKEY_CURRENT_USER' -and $PathType -eq 'Container'
            }
            Mock Get-Item { [pscustomobject]@{ FullName = 'Registry::HKEY_CURRENT_USER' } } -ParameterFilter {
                $LiteralPath -eq 'Registry::HKEY_CURRENT_USER'
            }

            { & (Join-Path $script:OptionalWorkflowDirectory 'Set Desktop.ps1') } | Should -Throw '*DesktopPath*檔案系統*資料夾*'

            Should -Invoke Set-ItemProperty -Times 0
            Should -Invoke Stop-Process -Times 0
            Should -Invoke Start-Process -Times 0
        }
    }

    Context 'RDP 連接埠與防火牆規則' {
        It '拒絕非法連接埠 <Port>，且不存取登錄或防火牆' -ForEach @(
            @{ Port = '' }, @{ Port = 'abc' }, @{ Port = '0' }, @{ Port = '-1' },
            @{ Port = '65536' }, @{ Port = '1.5' }, @{ Port = '2147483648' }
        ) {
            Mock Read-Host -MockWith ({ $Port }.GetNewClosure())

            { & (Join-Path $script:OptionalWorkflowDirectory 'Change Remote Port.ps1') } | Should -Throw '*1*65535*'

            Should -Invoke Set-ItemProperty -Times 0
            Should -Invoke Get-NetFirewallRule -Times 0
            Should -Invoke New-NetFirewallRule -Times 0
            Should -Invoke Set-NetFirewallRule -Times 0
        }

        It '邊界連接埠 <Port> 建立 Private 與 Public 的 TCP／UDP 規則並啟用 RDP' -ForEach @(
            @{ Port = '1' }, @{ Port = '65535' }
        ) {
            Mock Read-Host -MockWith ({ $Port }.GetNewClosure())

            & (Join-Path $script:OptionalWorkflowDirectory 'Change Remote Port.ps1')

            Should -Invoke Set-ItemProperty -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'PortNumber' -and $Value -is [int] -and $Value -eq [int]$Port
            }
            foreach ($expectedProtocol in @('TCP', 'UDP')) {
                Should -Invoke New-NetFirewallRule -Times 1 -Exactly -ParameterFilter {
                    $Name -eq "Refilling-RDP-$expectedProtocol-In" -and $Protocol -eq $expectedProtocol -and
                    $LocalPort -eq [int]$Port -and $Profile -contains 'Private' -and $Profile -contains 'Public' -and
                    @($Profile).Count -eq 2 -and $Direction -eq 'Inbound' -and $Action -eq 'Allow'
                }
            }
            Should -Invoke Set-ItemProperty -Times 1 -Exactly -ParameterFilter {
                $Name -eq 'fDenyTSConnections' -and $Value -eq 0
            }
        }

        It '重跑時更新既有兩條規則的連接埠，不新增重複規則' {
            $firewallState = @{ Rules = @{}; Port = '4400' }
            Mock Read-Host -MockWith ({ $firewallState.Port }.GetNewClosure())
            Mock Get-NetFirewallRule -MockWith ({ @($firewallState.Rules.Values) }.GetNewClosure())
            Mock New-NetFirewallRule -MockWith ({
                param($Name, $LocalPort)
                $firewallState.Rules[$Name] = [pscustomobject]@{ Name = $Name; Port = $LocalPort }
            }.GetNewClosure())
            Mock Set-NetFirewallRule -MockWith ({
                param($Name, $LocalPort)
                $firewallState.Rules[$Name].Port = $LocalPort
            }.GetNewClosure())

            & (Join-Path $script:OptionalWorkflowDirectory 'Change Remote Port.ps1')
            $firewallState.Port = '4401'
            & (Join-Path $script:OptionalWorkflowDirectory 'Change Remote Port.ps1')

            $firewallState.Rules.Count | Should -Be 2
            $firewallState.Rules['Refilling-RDP-TCP-In'].Port | Should -Be 4401
            $firewallState.Rules['Refilling-RDP-UDP-In'].Port | Should -Be 4401
            Should -Invoke New-NetFirewallRule -Times 2 -Exactly
            Should -Invoke Set-NetFirewallRule -Times 2 -Exactly -ParameterFilter {
                $Profile -contains 'Private' -and $Profile -contains 'Public'
            }
        }
    }
}
