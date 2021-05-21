Set-ExecutionPolicy AllSigned
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install googlechrome -y
choco install line -y
choco install teamviewer -y
choco install telegram -y
choco install 7zip -y

choco install adobereader -y
choco install libreoffice-fresh -y
choco install discord -y
choco install postman -y
choco install vscode -y

choco install nodejs -y
choco install git -y
choco install sourcetree -y
choco install visualstudio2019community -y
choco install sql-server-management-studio -y

choco install potplayer -y
choco install microsoft-teams -y
choco install docker-desktop -y


