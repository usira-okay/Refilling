function Update-RefillingTerminalSettings {
    <#
    .SYNOPSIS
    建立更新後的 Terminal 設定，保留使用者設定且不修改輸入物件。
    .PARAMETER Settings
    以 ConvertFrom-Json -AsHashtable 讀取的設定物件。
    .PARAMETER ProfilePath
    開啟 PowerShell 時要載入的個人 Profile 完整路徑。
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$Settings,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ProfilePath
    )

    $powerShellSource = 'Windows.Terminal.PowershellCore'
    $powerShellGuid = '{574e775e-4f2a-5b96-ac1e-a2962a402336}'
    $agentGuid = '{bf89599a-06b4-4ee5-bf49-72e4fb5c0eab}'
    $fontFace = 'Maple Mono NF CN'

    if ($Settings -isnot [System.Collections.IDictionary]) {
        throw 'Windows Terminal 設定根節點必須是物件。'
    }

    $profiles = @{}
    if ($Settings.Contains('profiles')) {
        if ($Settings['profiles'] -isnot [System.Collections.IDictionary]) {
            throw 'Windows Terminal profiles 必須是物件。'
        }
        $profiles = [hashtable]::new($Settings['profiles'])
    }

    $profileList = @()
    if ($profiles.ContainsKey('list')) {
        if ($profiles['list'] -isnot [System.Collections.IList]) {
            throw 'Windows Terminal profiles.list 必須是陣列。'
        }
        $profileList = [object[]]$profiles['list']
    }

    $powerShellIndex = -1
    $namedPowerShellIndex = -1
    $agentIndex = -1
    $namedAgentIndex = -1
    for ($index = 0; $index -lt $profileList.Count; $index++) {
        $profile = $profileList[$index]
        if ($profile -isnot [System.Collections.IDictionary]) {
            throw "Windows Terminal profiles.list[$index] 的 profile 必須是物件。"
        }
        if ($powerShellIndex -lt 0 -and $profile['source'] -eq $powerShellSource) {
            $powerShellIndex = $index
        }
        if ($namedPowerShellIndex -lt 0 -and $profile['name'] -eq 'PowerShell') {
            $namedPowerShellIndex = $index
        }
        if ($agentIndex -lt 0 -and ([string]$profile['guid']).Trim('{}') -eq $agentGuid.Trim('{}')) {
            $agentIndex = $index
        }
        if ($namedAgentIndex -lt 0 -and $profile['name'] -eq 'agent-dev') {
            $namedAgentIndex = $index
        }
    }

    if ($powerShellIndex -lt 0) { $powerShellIndex = $namedPowerShellIndex }
    if ($agentIndex -lt 0) { $agentIndex = $namedAgentIndex }

    $powerShellProfile = if ($powerShellIndex -ge 0) {
        [hashtable]::new($profileList[$powerShellIndex])
    } else {
        @{ source = $powerShellSource; hidden = $false }
    }
    $agentProfile = if ($agentIndex -ge 0) {
        [hashtable]::new($profileList[$agentIndex])
    } else {
        @{ colorScheme = 'Campbell'; hidden = $false; icon = 'none'; startingDirectory = '%USERPROFILE%' }
    }

    # PowerShell 也將彎單引號視為分隔符，須成對跳脫才能保留路徑原文。
    $escapedProfilePath = [regex]::Replace($ProfilePath, "['\u2018-\u201B]", '$0$0')
    $profileCommand = ". '$escapedProfilePath'"
    $targets = @(
        @{ Profile = $powerShellProfile; Name = 'PowerShell'; Guid = $powerShellGuid; Command = $profileCommand }
        @{ Profile = $agentProfile; Name = 'agent-dev'; Guid = $agentGuid; Command = "$profileCommand && de agent-dev" }
    )
    foreach ($target in $targets) {
        $profile = $target.Profile
        if (-not $profile['name']) { $profile['name'] = $target.Name }
        if (-not $profile['guid']) { $profile['guid'] = $target.Guid }
        if ($profile.ContainsKey('font') -and $profile['font'] -isnot [System.Collections.IDictionary]) {
            throw "Windows Terminal profile '$($profile['name'])' 的 font 必須是物件。"
        }
        $profile['font'] = if ($profile.ContainsKey('font')) {
            [hashtable]::new($profile['font'])
        } else {
            @{}
        }
        $profile['font']['face'] = $fontFace
        $encodedCommand = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($target.Command))
        $profile['commandline'] = "pwsh -NoExit -EncodedCommand $encodedCommand"
    }

    $otherProfiles = @(for ($index = 0; $index -lt $profileList.Count; $index++) {
        if ($index -ne $powerShellIndex -and $index -ne $agentIndex) {
            $profileList[$index]
        }
    })
    $profiles['list'] = @($powerShellProfile, $agentProfile) + @($otherProfiles)
    $result = [hashtable]::new($Settings)
    $result['profiles'] = $profiles
    $result['defaultProfile'] = $powerShellProfile['guid']
    return $result
}

function Set-RefillingTerminalSettings {
    <#
    .SYNOPSIS
    驗證 Terminal 設定後保留原始備份，並以完整暫存檔取代設定檔。
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SettingsPath,
        [Parameter(Mandatory)]
        [string]$ProfilePath
    )

    $ErrorActionPreference = 'Stop'
    $settings = @{}
    $settingsExist = Test-Path -LiteralPath $SettingsPath
    if ($settingsExist) {
        $content = Get-Content -LiteralPath $SettingsPath -Raw
        if ([string]::IsNullOrWhiteSpace($content)) {
            throw "Windows Terminal 設定不可為空：$SettingsPath"
        }
        $settings = ConvertFrom-Json -InputObject $content -AsHashtable
    }
    $updatedSettings = Update-RefillingTerminalSettings -Settings $settings -ProfilePath $ProfilePath
    $json = ConvertTo-Json -InputObject $updatedSettings -Depth 100 -WarningAction Stop

    $directory = Split-Path -LiteralPath $SettingsPath
    [System.IO.Directory]::CreateDirectory($directory) | Out-Null
    if ($settingsExist) {
        $backupPath = "$SettingsPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss_fff')"
        [System.IO.File]::Copy($SettingsPath, $backupPath)
        Write-Host "已備份 Terminal 設定至 $backupPath" -ForegroundColor Yellow
    }

    # 先寫完同目錄的暫存檔，寫入失敗時保留原設定檔。
    $temporaryPath = "$SettingsPath.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        [System.IO.File]::WriteAllText($temporaryPath, $json, [System.Text.UTF8Encoding]::new($false))
        [System.IO.File]::Move($temporaryPath, $SettingsPath, $true)
    } finally {
        if ([System.IO.File]::Exists($temporaryPath)) {
            [System.IO.File]::Delete($temporaryPath)
        }
    }
}
