Set-ExecutionPolicy AllSigned
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install googlechrome -y
choco install line -y
choco install sql-server-management-studio -y
choco install postman -y
choco install fiddler -y
choco install filezilla -y
choco install teamviewer -y
choco install vscode -y
choco install visualstudio2019community -y
choco install sourcetree -y
choco install telegram -y
choco install spotify -y
choco install 7zip -y
choco install adobereader -y
choco install google-backup-and-sync -y
choco install git -y
choco install nodejs -y
choco install lbry -y
choco install steam -y