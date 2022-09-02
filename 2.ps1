function Test-Administrator { $user = [Security.Principal.WindowsIdentity]::GetCurrent(); (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) } 

if (Test-Administrator) { 

    # Add US and TW Keyboard
    $UserLanguageList = New-WinUserLanguageList -Language "zh-TW"
    $UserLanguageList.Add("en-US")
    Set-WinUserLanguageList -LanguageList $UserLanguageList -Force
    Set-WinDefaultInputMethodOverride -InputTip "0409:00000409"

    # Install Applications by Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    choco install tortoisegit `
        linqpad `
        sqlpackage `
        googlechrome `
        line `
        teamviewer `
        telegram `
        7zip `
        adobereader `
        discord `
        postman `
        vscode `
        nodejs-lts `
        git `
        sourcetree `
        potplayer `
        microsoft-teams `
        docker-desktop `
        wsl2 `
        openshot `
        obs-studio `
        zoom `
        nuget.commandline `
        steam-client `
        ngrok `
        skype `
        filezilla `
        yt-dlp `
        ffmpeg `
        flameshot `
        devtoys `
        dropbox `
        coretemp `
        speedtest-by-ookla `
        sql-server-management-studio `
        visualstudio2019community --package-parameters "--allWorkloads --passive --locale en-US" `
        visualstudio2019enterprise --package-parameters "--allWorkloads --passive --locale en-US" `
        visualstudio2022community --package-parameters "--allWorkloads --passive --locale en-US" `
        visualstudio2022enterprise --package-parameters "--allWorkloads --passive --locale en-US" `
        office365business -y

    # Refresh Chocolatey environment 
    $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.." 

    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

    refreshenv

    # Install develoment tools
    npm i -g @angular/cli
    code --install-extension "shan.code-settings-sync"
    npm i -g nswag

    # Add Nuget Offical Source
    nuget source add -name nuget -source https://api.nuget.org/v3/index.json

    # 右鍵選單設定成 win10 版的
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve

    # 清除右鍵選單的按鈕
    reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\git_gui" /f
    reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\git_shell" /f
    reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\AnyCode" /f

    Restart-Computer

}
else {
    Write-Host "Not admin!"
}
