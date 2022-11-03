#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance Force
DetectHiddenWindows, On
FileReadLine, AutoLaunchGT, %A_WorkingDir%\GTAutoUpdater\AutoLaunchGT, 1

Gui, Font, c00FF00 s12, Consolas
Gui, Color, 000000
Gui, -Sysmenu
Gui, Add, Text, w500 Center vProgressText, Checking version...
Gui, Show, Center, Growtopia Auto Updater

; Check current version
If !FileExist(A_WorkingDir . "\Growtopia.exe")
{
	GuiControl, , ProgressText, Couldn't find a Growtopia executable. Make sure you've installed Growtopia Auto Updater correctly!
	MsgBox, 0, Growtopia Auto Updater, Failed to check, 10
	ExitApp
}
FileRead, GTBin, *c Growtopia.exe
FileGetSize, GTFileSize, %A_WorkingDir%\Growtopia.exe
offset := 0
Loop
{
	nget := NumGet(GTBin, offset, "Int64")
	If (nget = 4586465859858123981)
	{
		GTVersion := NumGet(GTBin, offset + 8, "Float")
		Break
	}
	offset += 8
	If(offset > GTFileSize)
	{
		GuiControl, , ProgressText, Failed to check
		MsgBox, 0, Growtopia Auto Updater, Couldn't get Growtopia version, 10
		ExitApp
	}
}
GTVersion := Format("{:.2f}", GTVersion)
GTBin := "0"
GuiControl, , ProgressText, Current version : v%GTVersion% | Checking for updates...
; Check new version
If not ConnectedToInternet()
{
	GuiControl, , ProgressText, Failed to check
	MsgBox, 0, Growtopia Auto Updater, Cannot check for updates as system is not connected to the internet, 10
	ExitApp
}
FileDelete, %A_WorkingDir%\GTAutoUpdater\ver
RunWait, %A_WorkingDir%\GTAutoUpdater\versionscrape, %A_WorkingDir%\GTAutoUpdater\, Hide
If !FileExist(A_WorkingDir . "\GTAutoUpdater\ver")
{
	GuiControl, , ProgressText, Failed to check
	MsgBox, 0, Growtopia Auto Updater, Cannot check for updates as the server has timed out, 10
	ExitApp
}
FileRead, FVer, %A_WorkingDir%\GTAutoUpdater\ver
FVer := StrSplit(FVer, ",")
ccount := FVer.MaxIndex()
Loop, %ccount%
{
	If InStr(FVer[A_Index], "'version':")
	{
		NewGTVer := SubStr(FVer[A_Index], 14, 4)
		NewGTVer := Format("{:.2f}", NewGTVer)
		GTVerCheck := true
		If(NewGTVer > GTVersion)
		{
			GuiControl, , ProgressText, A new version of Growtopia is available! (v%NewGTVer%)
			Gosub, UpdateGT
		}
		Else
			GuiControl, , ProgressText, Latest Growtopia version : v%GTVersion%
		FileDelete, %A_WorkingDir%\GTAutoUpdater\ver
		If !WinExist("ahk_class AppClass ahk_exe Growtopia.exe") and AutoLaunchGT		
			Run, Growtopia.exe, %A_WorkingDir%
		Sleep, 3000
		ExitApp
	}
}
GuiControl, , ProgressText, Unable to fetch latest Growtopia version
MsgBox, 0, Growtopia Auto Updater, Unable to fetch latest Growtopia version, 10
ExitApp

UpdateGT:
MsgBox, 260, Growtopia Auto Updater, A new version of Growtopia is available. Update now?, 10
IfMsgBox No
	Return
If not ConnectedToInternet()
{
	GuiControl, , ProgressText, Failed to update
	MsgBox, 0, Growtopia Auto Updater, Cannot update Growtopia as system is not connected to the internet, 10
	Return
}
GuiControl, , ProgressText, Downloading Growtopia...
FileDelete, %A_Temp%\GTAU\Growtopia-Installer.exe
FileRemoveDir, %A_Temp%\GTAU\Growtopia-Installer\, 1
FileCreateDir, %A_Temp%\GTAU\Growtopia-Installer\
DownloadFile("https://growtopiagame.com/Growtopia-Installer.exe", A_Temp . "\GTAU\Growtopia-Installer.exe")
If ErrorLevel
{
	GuiControl, , ProgressText, Failed to update
	MsgBox, 0, Growtopia Auto Updater, Cannot update Growtopia as server has timed out, 10
	Return
}
GuiControl, , ProgressText, Updating Growtopia...
If WinExist("ahk_exe growtopia.exe ahk_class AppClass")
{
	WinClose, Growtopia ahk_class AppClass
	WinWaitClose, Growtopia ahk_class AppClass
}
RunWait, %ComSpec% /c 7z x -aou -o"%A_Temp%\GTAU\Growtopia-Installer\" "%A_Temp%\GTAU\Growtopia-Installer.exe", %A_WorkingDir%\GTAutoUpdater\, Hide
If !FileExist(A_Temp . "\GTAU\Growtopia-Installer\Growtopia.exe")
{
	GuiControl, , ProgressText, Cannot update Growtopia
	MsgBox, 0, Growtopia Auto Updater, Cannot update Growtopia, installation may have been corrupted
	Return
}
FileRemoveDir, %A_Temp%\GTAU\Growtopia-Installer\$PLUGINSDIR, 1
FileDelete, %A_Temp%\GTAU\Growtopia-Installer\Uninstall.exe.nsis
FileDelete, %A_Temp%\GTAU\Growtopia-Installer\vc_redist.x64.exe
FileDelete, %A_Temp%\GTAU\Growtopia-Installer\vc_redist.x86.exe

;Delete 32 or 64
If A_Is64bitOS
{
	FileDelete, %A_Temp%\GTAU\Growtopia-Installer\Growtopia_1.exe
	FileDelete, %A_Temp%\GTAU\Growtopia-Installer\ubiservices_1.dll
}
Else
{
	FileDelete, %A_Temp%\GTAU\Growtopia-Installer\Growtopia.exe
	FileDelete, %A_Temp%\GTAU\Growtopia-Installer\ubiservices.dll
	FileMove, %A_Temp%\GTAU\Growtopia-Installer\Growtopia_1.exe, %A_Temp%\GTAU\Growtopia-Installer\Growtopia.exe, 1
	FileMove, %A_Temp%\GTAU\Growtopia-Installer\ubiservices_1.dll, %A_Temp%\GTAU\Growtopia-Installer\ubiservices.dll, 1
}
FileCopyDir, %A_Temp%\GTAU\Growtopia-Installer, %A_WorkingDir%, 1
FileDelete, %A_Temp%\GTAU\Growtopia-Installer.exe
FileRemoveDir, %A_Temp%\GTAU\Growtopia-Installer\, 1
GuiControl, , ProgressText, Growtopia has been updated to v%NewGTVer%
MsgBox, 0, Growtopia Auto Updater, Growtopia has been updated to v%NewGTVer%
Return

ConnectedToInternet(flag=0x40) { 
Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag,"Int",0) 
}

DownloadFile(URL, Target)
{
	SplitPath, Target, FName
	SizeNow := HttpQueryInfo(URL, 5)
	FileGetSize, SizeDL, %Target%
	If(SizeNow = SizeDL)
	{
		Return 0
	}
	FileDelete, %Target%
	Dvsor := 1
	Denom := "B"
	If(SizeNow > 1000)
	{
		Dvsor := 1000
		Denom := "KB"
	}
	If(SizeNow > 1000000)
	{
		Dvsor := 1000000
		Denom := "MB"
	}
	SizeNow := Format("{:.2f}", SizeNow / Dvsor)
	SetTimer, DownloadFile_GetSize, 250
	UrlDownloadToFile, %URL%, %Target%
	DownloadError := ErrorLevel
	SetTimer, DownloadFile_GetSize, Off
	If DownloadError
		Return 1
	Else
		Return 0
	DownloadFile_GetSize:
	FileGetSize, SizeDL, %Target%
	SizeDL := Format("{:.2f}", SizeDL / Dvsor)
	DLPercent := Format("{:.1f}", 100 * SizeDL / SizeNow)
	GuiControl, , ProgressText, Downloading Growtopia... (%SizeDL% %Denom% of %SizeNow% %Denom%) (%DLPercent%`%)
	Return
}

HttpQueryInfo(URL, QueryInfoFlag=21, Proxy := "", ProxyBypass := "") {
 ; https://autohotkey.com/board/topic/10384-download-progress-bar/
 hModule := DllCall("LoadLibrary", "str", dll := "wininet.dll")
 ver := (A_IsUnicode && !RegExMatch(A_AhkVersion, "\d+\.\d+\.4") ? "W" : "A")
 InternetOpen := dll "\InternetOpen" ver, HttpQueryInfo := dll "\HttpQueryInfo" ver
 InternetOpenUrl := dll "\InternetOpenUrl" ver, AccessType := Proxy > "" ? 3 : 1
 io_hInternet := DllCall(InternetOpen, "str", "", "uint", AccessType, "str", Proxy
                       , "str", ProxyBypass, "uint", 0)
 If (ErrorLevel || io_hInternet = 0) {
  DllCall("FreeLibrary", "uint", hModule)
  Return -1
 } Else iou_hInternet := DllCall(InternetOpenUrl, "uint", io_hInternet, "str", url, "str", ""
                       , "uint", 0, "uint", 0x80000000, "uint", 0)
 If (ErrorLevel || iou_hInternet = 0) {
  DllCall("FreeLibrary", "uint", hModule)
  Return -1
 } Else VarSetCapacity(buffer, 1024, 0), VarSetCapacity(buffer_len, 4, 0)
 Loop, 5 {
  hqi := DllCall(HttpQueryInfo, "uint", iou_hInternet, "uint", QueryInfoFlag, "uint", &buffer
               , "uint", &buffer_len, "uint", 0)
  If (hqi = 1) {
    hqi = success
    Break
  }
 }
 If (hqi = "success") {
  p := &buffer
  Loop {
   l := DllCall("lstrlen", "UInt", p), VarSetCapacity(tmp_var, l+1, 0)
   DllCall("lstrcpy", "Str", tmp_var, "UInt", p)
   p += l + 1
   res .= tmp_var
   If (*p = 0)
    Break
  }
 } Else SetEnv, res, timeout
 DllCall("wininet\InternetCloseHandle",  "uint", iou_hInternet)
 DllCall("wininet\InternetCloseHandle",  "uint", io_hInternet)
 DllCall("FreeLibrary", "uint", hModule)
 Return res
}
^+e::
AutoLaunchGT := 0
Return
^+r::
AutoLaunchGT := 1
Return