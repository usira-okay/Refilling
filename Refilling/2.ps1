$workDir = [System.IO.Path]::GetDirectoryName($PSCommandPath)

Set-Location $workDir

. ..\Test-Administrator.ps1

if (Test-Administrator) { 

    Write-Host 'Add US and TW Keyboard'
    # Add US and TW Keyboard
    $UserLanguageList = New-WinUserLanguageList -Language "zh-TW"
    $UserLanguageList.Add("en-US")
    Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
    Set-WinDefaultInputMethodOverride -InputTip "0409:00000409"
   
    Write-Host 'Install AzureCLI'
    # Install AzureCLI
    $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi
   
    Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
    
    Write-Host 'Install Applications by Chocolatey'
    # Install Applications by Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    choco install linqpad7 -y --ignore-checksums

    choco install tortoisegit `
        googledrive `
        sizer `
        sqlpackage `
        brave `
        line `
        teamviewer `
        7zip `
        adobereader `
        discord `
        postman `
        vscode `
        nodejs-lts `
        git `
        sourcetree `
        potplayer `
        openshot `
        obs-studio `
        zoom `
        steam-client `
        ngrok `
        filezilla `
        yt-dlp `
        ffmpeg `
        flameshot `
        devtoys `
        coretemp `
        nuget.commandline `
        speedtest-by-ookla `
        sql-server-management-studio `
        visualstudio2019community --package-parameters "--allWorkloads --passive --locale en-US" `
        visualstudio2022community --package-parameters "--allWorkloads --passive --locale en-US" -y

    # Refresh Chocolatey environment 
    $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.." 

    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

    refreshenv

    # Install develoment tools
    code --install-extension "shan.code-settings-sync"

    # Install SWA CLI
    npm install -g @azure/static-web-apps-cli

    # Add Nuget Offical Source
    nuget source add -name nuget -source https://api.nuget.org/v3/index.json
    
    # 右鍵選單設定成 win10 版的
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve

    pause

}
else {
    Start-Process Powershell -Verb RunAs -ArgumentList " $PSCommandPath ''" 
}
