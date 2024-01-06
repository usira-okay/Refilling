Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath



Write-Host 'Visual Studio'

$vsUrls = 'https://aka.ms/vs/17/release/vs_community.exe', 'https://c2rsetup.officeapps.live.com/c2r/downloadVS.aspx?sku=community&channel=Preview&version=VS2022&source=VSLandingPage&cid=2060';
''
foreach ($url in $vsUrls) {
    Invoke-WebRequest -Uri $url -OutFile .\installer.exe
    
    $process = Start-Process -FilePath installer.exe -ArgumentList "--allWorkloads", "--passive", "--installWhileDownloading", "--locale en-US", "--wait" -Wait -PassThru
    Write-Output $process.ExitCode 
}

Pause
