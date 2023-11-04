
Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope CurrentUser -Force

# 停用預設的 print screen 快捷鍵
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -Value 0
