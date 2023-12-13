
^#!a::

Run, shutdown -a

return

^#!r::

Run, shutdown -r -t 10 -f

return

^#!s::

Run, shutdown -s -t 10 -f

return

#!d::

path := GetPath() 

Run, %path%

return

#!c::

path := GetPath() 

Run, wt.exe -w normal new-tab PowerShell -NoExit -Command cd '%path%'

return

#!v::

path := GetPath() 

#NoEnv
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

; 獲取使用者名稱
EnvGet, username, USERNAME

; 設定VSCode的安裝路徑
vscodePath := "C:\Users\" . username . "\AppData\Local\Programs\Microsoft VS Code\Code.exe"

; 執行指令啟動VSCode並開啟指定資料夾
Run, %vscodePath% "%path%"

return

#!space::

path := GetPath() 

Run, *RunAs wt.exe -w administrator new-tab PowerShell -NoExit -Command cd '%path%'

return

GetActiveExplorerPath()
{
	explorerHwnd := WinActive("ahk_class CabinetWClass")
	if (explorerHwnd)
	{
		for window in ComObjCreate("Shell.Application").Windows
		{
			if (window.hwnd==explorerHwnd)
			{
				return window.Document.Folder.Self.Path
			}
		}
	}
    return %A_Desktop%
}

GetPath()
{
	dirpath := GetActiveExplorerPath()
	
	return dirpath
}