# 先啟動 ssh-agent
eval "$(ssh-agent -s)"

mkdir ~/.ssh
cd ~/.ssh


ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/your_key_name


ssh-add ~/.ssh/your_key_name

