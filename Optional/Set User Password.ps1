#requires -Version 5.1
<# .SYNOPSIS 確認兩次密碼完全一致後更新目前帳號，並清除比較用的非受控記憶體。 #>
$repositoryRoot = Split-Path $PSScriptRoot -Parent
if (-not (. (Join-Path $repositoryRoot 'Common.ps1') -CallerPath $PSCommandPath)) { return }

$password1 = Read-Host '請輸入新密碼' -AsSecureString
$password2 = Read-Host '請再次輸入新密碼' -AsSecureString
$ptr1 = [IntPtr]::Zero
$ptr2 = [IntPtr]::Zero
$plaintextPassword1 = $null
$plaintextPassword2 = $null

try {
    $ptr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password1)
    $plaintextPassword1 = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr1)
    $ptr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password2)
    $plaintextPassword2 = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr2)

    if (-not [string]::Equals($plaintextPassword1, $plaintextPassword2, [StringComparison]::Ordinal)) {
        throw '兩次密碼輸入不一致。'
    }
    Get-LocalUser -Name $env:USERNAME | Set-LocalUser -Password $password1
} finally {
    if ($ptr1 -ne [IntPtr]::Zero) {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr1)
    }
    if ($ptr2 -ne [IntPtr]::Zero) {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr2)
    }
    $plaintextPassword1 = $null
    $plaintextPassword2 = $null
}

Write-Host '密碼更新完成。' -ForegroundColor Green
Pause
