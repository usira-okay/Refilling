
#!c::

path := GetPath() 

Run, wt.exe -w normal new-tab PowerShell -NoExit -Command cd '%path%'

return

#!v::

path := GetPath() 

Run, powershell.exe -Command code '%path%'

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