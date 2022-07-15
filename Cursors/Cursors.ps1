function Test-Administrator { $user = [Security.Principal.WindowsIdentity]::GetCurrent(); (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) } 
$dirName = "Numix Dark"

if ((Test-Administrator) -and (test-path ".\$dirName")) {   

    $cursors = "$env:systemroot\Cursors\$dirName"

    Copy-Item -Path ".\$dirName" -Destination $cursors -Recurse

    $RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser", "$env:COMPUTERNAME")

    $RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors", $true)

    $RegCursors.SetValue("", $cursors)

    $RegCursors.SetValue("AppStarting", "$cursors\AppStarting.ani")

    $RegCursors.SetValue("Arrow", "$cursors\Arrow.cur")

    $RegCursors.SetValue("Crosshair", "$cursors\Cross.cur")

    $RegCursors.SetValue("Hand", "$cursors\Hand.cur")

    $RegCursors.SetValue("Help", "$cursors\Help.cur")

    $RegCursors.SetValue("IBeam", "$cursors\IBeam.cur")

    $RegCursors.SetValue("No", "$cursors\NO.cur")

    $RegCursors.SetValue("NWPen", "$cursors\Handwriting.cur")

    $RegCursors.SetValue("SizeAll", "$cursors\SizeAll.cur")

    $RegCursors.SetValue("SizeNESW", "$cursors\SizeNESW.cur")

    $RegCursors.SetValue("SizeNS", "$cursors\SizeNS.cur")

    $RegCursors.SetValue("SizeNWSE", "$cursors\SizeNWSE.cur")

    $RegCursors.SetValue("SizeWE", "$cursors\SizeWE.cur")

    $RegCursors.SetValue("UpArrow", "$cursors\UpArrow.cur")

    $RegCursors.SetValue("Wait", "$cursors\Wait.ani")

    $RegCursors.Close()

    $RegConnect.Close()

    $CSharpSig = @"
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(uint uiAction,uint uiParam,uint pvParam,uint fWinIni);
"@

    $CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo -PassThru
    $CursorRefresh::SystemParametersInfo(0x0057, 0, $null, 0)

} else {
    Write-Host "Not admin or dir not found !"
}
