
^#!a::

Run, shutdown -a

return

^#!r::

Run, shutdown -r -t 10 -f

return

^#!s::

Run, shutdown -s -t 10 -f

return

#!p::

SendInput, {U+FF0C}{U+518D}{U+9EBB}{U+7169}{U+5354}{U+52A9} review {&} merge {U+611F}{U+8B1D}

return

#!c::

path := GetPath() 

profile := GetPowerShellProfilePath()

Run, "C:\Users\ari\AppData\Local\Microsoft\WindowsApps\pwsh.exe" -NoExit -Command ". %profile% && cd '%path%'"

return

#!space::

path := GetPath() 

profile := GetPowerShellProfilePath()

Run, *RunAs "C:\Users\ari\AppData\Local\Microsoft\WindowsApps\pwsh.exe" -NoExit -Command ". %profile% && cd '%path%'"

return

#!v::

path := GetPath() 

Run, "C:\Users\ari\AppData\Local\Microsoft\WindowsApps\pwsh.exe" -NoProfile -WindowStyle Hidden -Command "code '%path%'", , Hide
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

GetPowerShellProfilePath()
{
	; 獲取使用者名稱
	EnvGet, userprofile, USERPROFILE

	profile := userprofile . "\Microsoft.PowerShell_profile.ps1"

	return profile
}