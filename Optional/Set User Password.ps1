Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. ..\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Set User Password'

$newpassword = ConvertTo-SecureString "YourNewPassword" -AsPlainText -Force
$user = Get-LocalUser -Name $env:USERNAME
$user | Set-LocalUser -Password $newpassword
