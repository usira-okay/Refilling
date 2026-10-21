# 此檔亦供 Windows PowerShell 5.1 的第 0 階段載入，僅定義函式，不變更系統。

function Invoke-ExternalCommand {
    <#
    .SYNOPSIS
    執行外部工具並驗證其結束碼，保留標準輸出供呼叫端使用。
    .PARAMETER SuccessExitCodes
    工具文件定義的成功碼；需要重新開機的代碼須由呼叫端明確列入。
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $FilePath,
        [string[]] $ArgumentList = @(),
        [int[]] $SuccessExitCodes = @(0)
    )

    $ErrorActionPreference = 'Stop'
    $PSNativeCommandUseErrorActionPreference = $false
    # Scoop 等 PowerShell 包裝腳本可能未設定結束碼，不能沿用上一個程序的值。
    $global:LASTEXITCODE = 0
    & $FilePath @ArgumentList
    $exitCode = $global:LASTEXITCODE
    if ($exitCode -notin $SuccessExitCodes) {
        throw "外部命令失敗：$FilePath（結束碼 $exitCode）。請查看上方輸出後再繼續佈建。"
    }
}

function Test-IsAdministrator {
    <# .SYNOPSIS 判斷目前 Windows 程序是否具備管理員權限。 #>
    [CmdletBinding()]
    param()

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Add-RefillingNuGetSource {
    <# .SYNOPSIS 僅在官方 NuGet 來源缺少時新增，避免把多行輸出誤判為不存在。 #>
    [CmdletBinding()]
    param()

    $sourceUrl = 'https://api.nuget.org/v3/index.json'
    $sources = Invoke-ExternalCommand -FilePath dotnet -ArgumentList @('nuget', 'list', 'source')
    if (-not ($sources -match [regex]::Escape($sourceUrl))) {
        Invoke-ExternalCommand -FilePath dotnet -ArgumentList @('nuget', 'add', 'source', '--name', 'nuget.org', $sourceUrl)
    } else {
        Write-Host 'nuget.org 來源已存在，跳過' -ForegroundColor Yellow
    }
}

function Get-RefillingPowerToysPath {
    <# .SYNOPSIS 尋找 PowerToys 標準使用者或電腦安裝位置，避免建立指向 Scoop 的無效捷徑。 #>
    [CmdletBinding()]
    param()

    foreach ($root in @($env:LOCALAPPDATA, $env:ProgramFiles)) {
        if ([string]::IsNullOrWhiteSpace($root)) { continue }
        $candidate = Join-Path $root 'PowerToys/PowerToys.exe'
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    throw '找不到 PowerToys.exe，請確認第 2 階段的 PowerToys 安裝已完成。'
}
