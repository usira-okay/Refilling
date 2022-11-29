$workDir = [System.IO.Path]::GetDirectoryName($PSCommandPath)
$workDir = [System.IO.Path]::GetDirectoryName($workDir)

Write-Host 'Change Cursors'

$dirName = 'Numix Dark'
$path = "$workDir\Cursors\$dirName"

if (-not (test-path $path)) {
    Write-Host "$dirName not found !"
    pause
    exit
}
    
$cursors = "$env:systemroot\Cursors\$dirName"

if (-not (test-path $cursors)) {
    Copy-Item -Path $path -Destination $cursors -Recurse
}

$RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]'CurrentUser', $env:COMPUTERNAME)

$RegCursors = $RegConnect.OpenSubKey('Control Panel\Cursors', $true)

$RegCursors.SetValue('', $cursors)

$RegCursors.SetValue('AppStarting', "$cursors\AppStarting.ani")

$RegCursors.SetValue('Arrow', "$cursors\Arrow.cur")

$RegCursors.SetValue('Crosshair', "$cursors\Cross.cur")

$RegCursors.SetValue('Hand', "$cursors\Hand.cur")

$RegCursors.SetValue('Help', "$cursors\Help.cur")

$RegCursors.SetValue('IBeam', "$cursors\IBeam.cur")

$RegCursors.SetValue('No', "$cursors\NO.cur")

$RegCursors.SetValue('NWPen', "$cursors\Handwriting.cur")

$RegCursors.SetValue('SizeAll', "$cursors\SizeAll.cur")

$RegCursors.SetValue('SizeNESW', "$cursors\SizeNESW.cur")

$RegCursors.SetValue('SizeNS', "$cursors\SizeNS.cur")

$RegCursors.SetValue('SizeNWSE', "$cursors\SizeNWSE.cur")

$RegCursors.SetValue('SizeWE', "$cursors\SizeWE.cur")

$RegCursors.SetValue('UpArrow', "$cursors\UpArrow.cur")

$RegCursors.SetValue('Wait', "$cursors\Wait.ani")

$RegCursors.Close()

$RegConnect.Close()

$CSharpSig = @"
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(uint uiAction,uint uiParam,uint pvParam,uint fWinIni);
"@

$CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo -PassThru
$CursorRefresh::SystemParametersInfo(0x0057, 0, $null, 0)
        