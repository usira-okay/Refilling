Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. ..\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Set User Password'

# 要求使用者第一次輸入密碼
$password1 = Read-Host "Enter password" -AsSecureString

# 要求使用者第二次輸入密碼
$password2 = Read-Host "Enter password again" -AsSecureString

# 將 SecureString 轉換為普通字串以便比較
$ptr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password1)
$plaintextPassword1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr1)

$ptr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password2)
$plaintextPassword2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr2)

# 比較兩次輸入的密碼
if ($plaintextPassword1 -eq $plaintextPassword2) {
    Write-Host "Password match."
    $user = Get-LocalUser -Name $env:USERNAME
    $user | Set-LocalUser -Password $password1
}


Pause
