# 重新加入 Microsoft 套件來源
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update

# 啟用 Universe 套件庫
sudo add-apt-repository universe
sudo apt-get update

# 安裝 .NET 6 SDK
sudo apt-get install -y dotnet-sdk-6.0



sudo add-apt-repository ppa:dotnet/backports

# 安裝 .NET 8 9 SDK
sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-6.0 dotnet-sdk-8.0 dotnet-sdk-9.0