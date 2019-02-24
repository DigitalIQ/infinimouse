#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Outfile=infinimouse.exe
#AutoIt3Wrapper_Res_Icon_Add=C:\Users\Manuel\infinimouse_dev\icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;
; InfiniMouse
;   an AutoIt script
;
; Author:  Ondrej Simek
; Fork & bugfixing: Manuel Bissinger
; License: MIT
;
; If you move mouse to one border, it'll come from the other.
;
; Works for multiple screens too, but will have issues if the screen
; layout doesn't make a perfect rectangle (e.g. for different
; resolutions).
;

;; Includes and Opts ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#include <AutoItConstants.au3>
#include <File.au3>
#include <TrayConstants.au3>
#include <MsgBoxConstants.au3>

Opt("TrayOnEventMode", 1)
Opt("TrayMenuMode", 3)
Opt("TrayAutoPause", 0)


;; Global Settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Global Const $PROGRAM_NAME = "InfiniMouse"
Global Const $INSTALL_DIR_PATH = @UserProfileDir & "\" & $PROGRAM_NAME
Global Const $INSTALL_SETTINGS_DIR_PATH = @AppDataDir & "\" & $PROGRAM_NAME
Global Const $INSTALL_SETTINGS_INI_PATH = $INSTALL_SETTINGS_DIR_PATH & "\settings.ini"
If DirCreate($INSTALL_SETTINGS_DIR_PATH) = 0 Then MsgBox($MB_SYSTEMMODAL, $PROGRAM_NAME & " - Error", $INSTALL_SETTINGS_DIR_PATH & " couldn't be created. Settings will not be stored persistent.")
Global Const $sStartupDirLink = @StartupDir & "\" & $PROGRAM_NAME & ".lnk"
Global Const $sInstallFullPath = $INSTALL_DIR_PATH & "\" & @ScriptName

Global $DisabledInfiniMouse = False


;; Tray Menu ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

$MenuItemLeftBorder = TrayCreateItem("Left border")
TrayItemSetOnEvent(-1, "_MenuItemEvent")
$MenuItemRightBorder = TrayCreateItem("Right border")
TrayItemSetOnEvent(-1, "_MenuItemEvent")
$MenuItemTopBorder = TrayCreateItem("Top border")
TrayItemSetOnEvent(-1, "_MenuItemEvent")
$MenuItemBottomBorder = TrayCreateItem("Bottom border")
TrayItemSetOnEvent(-1, "_MenuItemEvent")
TrayCreateItem("") ; separator
$MenuDelay = TrayCreateMenu("Delay")
$MenuDelayItem20 = TrayCreateItem("20ms", $MenuDelay)
TrayItemSetOnEvent(-1, "_MenuItemEvent")
$MenuDelayItem50 = TrayCreateItem("50ms", $MenuDelay)
TrayItemSetOnEvent(-1, "_MenuItemEvent")
$MenuDelayItem100 = TrayCreateItem("100ms", $MenuDelay)
TrayItemSetOnEvent(-1, "_MenuItemEvent")
$MenuDelayItem250 = TrayCreateItem("250ms", $MenuDelay)
TrayItemSetOnEvent(-1, "_MenuItemEvent")
$MenuDelayItem500 = TrayCreateItem("500ms", $MenuDelay)
TrayItemSetOnEvent(-1, "_MenuItemEvent")
TrayCreateItem("") ; separator
$MenuItemDisabled = TrayCreateItem("Disabled")
TrayItemSetOnEvent(-1, "_MenuItemEvent")
TrayCreateItem("") ; separator
$MenuItemUninstall = ""
If FileExists($sInstallFullPath) Then
	$MenuItemUninstall = TrayCreateItem("Uninstall")
	TrayItemSetOnEvent(-1, "_MenuItemEvent")
	TrayCreateItem("") ; separator
EndIf
$MenuItemRestart = TrayCreateItem("Restart")
TrayItemSetOnEvent(-1, "_MenuItemEvent")
TrayCreateItem("") ; separator
$MenuItemExit = TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "_MenuItemEvent")
TraySetIcon("shell32.dll", -239)
TraySetToolTip($PROGRAM_NAME)

;; Specific Settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func _ReadSettings()
	; IniRead() and IniWrite() doesn't work with booleans
	Global $EnableLeftBorder = _
		"true" = IniRead($INSTALL_SETTINGS_INI_PATH, "borders", "left", "true")
	Global $EnableRightBorder = _
		"true" = IniRead($INSTALL_SETTINGS_INI_PATH, "borders", "right", "true")
	Global $EnableTopBorder = _
		"true" = IniRead($INSTALL_SETTINGS_INI_PATH, "borders", "top", "false")
	Global $EnableBottomBorder = _
		"true" = IniRead($INSTALL_SETTINGS_INI_PATH, "borders", "bottom", "false")
	Local $iniDelay = IniRead($INSTALL_SETTINGS_INI_PATH, "general", "delay", 0)
	Global $Delay = $iniDelay <> 0 ? $iniDelay : 50
	Global $InstallWizard = "true" = IniRead($INSTALL_SETTINGS_INI_PATH, "general", "installwizard", "true")
	Global $Installed = "false" = IniRead($INSTALL_SETTINGS_INI_PATH, "general", "installed", "false")

	TrayItemSetState($MenuItemLeftBorder, _
		$EnableLeftBorder ? $TRAY_CHECKED : $TRAY_UNCHECKED)
	TrayItemSetState($MenuItemRightBorder, _
		$EnableRightBorder ? $TRAY_CHECKED : $TRAY_UNCHECKED)
	TrayItemSetState($MenuItemTopBorder, _
		$EnableTopBorder ? $TRAY_CHECKED : $TRAY_UNCHECKED)
	TrayItemSetState($MenuItemBottomBorder, _
		$EnableBottomBorder ? $TRAY_CHECKED : $TRAY_UNCHECKED)
	TrayItemSetState($MenuDelayItem20, _
		$Delay == 20 ? $TRAY_CHECKED : $TRAY_UNCHECKED)
	TrayItemSetState($MenuDelayItem50, _
		$Delay == 50 ? $TRAY_CHECKED : $TRAY_UNCHECKED)
	TrayItemSetState($MenuDelayItem100, _
		$Delay == 100 ? $TRAY_CHECKED : $TRAY_UNCHECKED)
	TrayItemSetState($MenuDelayItem250, _
		$Delay == 250 ? $TRAY_CHECKED : $TRAY_UNCHECKED)
	TrayItemSetState($MenuDelayItem500, _
		$Delay == 500 ? $TRAY_CHECKED : $TRAY_UNCHECKED)
	TrayItemSetState($MenuItemDisabled, _
		$DisabledInfiniMouse ? $TRAY_CHECKED : $TRAY_UNCHECKED)

EndFunc
_ReadSettings()

;; Tray Menu Events ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func _MenuItemEvent()
	Switch (@TRAY_ID)
		Case $MenuItemLeftBorder
			IniWrite($INSTALL_SETTINGS_INI_PATH, "borders", "left", _
			$EnableLeftBorder ? "false" : "true")
		Case $MenuItemRightBorder
			IniWrite($INSTALL_SETTINGS_INI_PATH, "borders", "right", _
			$EnableRightBorder ? "false" : "true")
		Case $MenuItemTopBorder
			IniWrite($INSTALL_SETTINGS_INI_PATH, "borders", "top", _
			$EnableTopBorder ? "false" : "true")
		Case $MenuItemBottomBorder
			IniWrite($INSTALL_SETTINGS_INI_PATH, "borders", "bottom", _
			$EnableBottomBorder ? "false" : "true")
		Case $MenuDelayItem20
			IniWrite($INSTALL_SETTINGS_INI_PATH, "general", "delay", 20)
		Case $MenuDelayItem50
			IniWrite($INSTALL_SETTINGS_INI_PATH, "general", "delay", 50)
		Case $MenuDelayItem100
			IniWrite($INSTALL_SETTINGS_INI_PATH, "general", "delay", 100)
		Case $MenuDelayItem250
			IniWrite($INSTALL_SETTINGS_INI_PATH, "general", "delay", 250)
		Case $MenuDelayItem500
			IniWrite($INSTALL_SETTINGS_INI_PATH, "general", "delay", 500)
		Case $MenuItemRestart
			_Restart()
		Case $MenuItemDisabled
			$DisabledInfiniMouse = $DisabledInfiniMouse == False ? True : False
		Case $MenuItemUninstall
			Switch MsgBox($MB_SYSTEMMODAL + $MB_YESNO, $PROGRAM_NAME & " - Deinstallation", "Do you really want to uninstall this program permanently?" & @CRLF & @CRLF & "This will delete the program and settings files and folders and remove the startup link.")
				Case $IDYES
					_Uninstall()
					Exit
				Case $IDNO
					; nothing to do here
			EndSwitch
		Case $MenuItemExit
			Exit
	EndSwitch
	_ReadSettings()
EndFunc

Func _Restart()
	If Not Run(@ScriptFullPath) Then MsgBox($MB_SYSTEMMODAL, $PROGRAM_NAME & " - Error", "Wrong file type." & @CRLF & "Program will be closed now. Please run it manually again.")
	Exit
EndFunc


;; Installation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func _Install()
	If $InstallWizard = "true" Then
		Switch MsgBox($MB_SYSTEMMODAL + $MB_YESNOCANCEL, $PROGRAM_NAME & " - Installation", "Do you want to install this program?" & @CRLF & @CRLF & "This will copy this program to " & $INSTALL_DIR_PATH & " and create a shortcut in the current user's Startup folder." & @CRLF & @CRLF & "If you click No you'll not be asked again to install " & $PROGRAM_NAME)
			Case $IDYES
				Local $sDrive, $sDir, $sFileName, $sExtension
				_PathSplit(@ScriptFullPath, $sDrive, $sDir, $sFileName, $sExtension)

				If $sExtension <> ".exe" Then
					MsgBox($MB_SYSTEMMODAL, $PROGRAM_NAME & " - Error", "Installation failed." & @CRLF & @CRLF & "Wrong file type. Program will be executed as a portable app.")
					ContinueCase
				EndIf

				If Not FileCopy(@ScriptFullPath, $INSTALL_DIR_PATH & "\", $FC_OVERWRITE + $FC_CREATEPATH) Then
					MsgBox($MB_SYSTEMMODAL, $PROGRAM_NAME & " - Error", "Installation failed." & @CRLF & @CRLF & "Copying file to " & $INSTALL_DIR_PATH & " failed.")
					ContinueCase
				EndIf

				If Not FileCreateShortcut($sInstallFullPath, $sStartupDirLink) Then
					MsgBox($MB_SYSTEMMODAL, $PROGRAM_NAME & " - Error", "Installation failed." & @CRLF & @CRLF & "Creating Startup link failed.")
					_Uninstall()
					ContinueCase
				EndIf

				If Not Run($sInstallFullPath) Then
					MsgBox($MB_SYSTEMMODAL, $PROGRAM_NAME & " - Error", "Installation failed." & @CRLF & @CRLF & "Wrong file type.")
					_Uninstall()
					ContinueCase
				EndIf

				IniWrite($INSTALL_SETTINGS_INI_PATH, "general", "installwizard", "false")
				IniWrite($INSTALL_SETTINGS_INI_PATH, "general", "installed", "true")

				Exit
			Case $IDYES
				; must be empty because of the use of ContinueCase in the previous Case statement
			Case $IDCANCEL
				; just continue with running the program
			Case $IDNO
				IniWrite($INSTALL_SETTINGS_INI_PATH, "general", "installwizard", "false")
		EndSwitch
	EndIf
EndFunc
_Install()


;; Uninstallation routine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func _Uninstall()
	DirRemove($INSTALL_DIR_PATH, $DIR_REMOVE)
	DirRemove($INSTALL_SETTINGS_DIR_PATH, $DIR_REMOVE)
	FileDelete($sStartupDirLink)
	MsgBox($MB_SYSTEMMODAL, $PROGRAM_NAME & " - Deinstallation", "Deinstallation finished." & @CRLF & @CRLF & "Program files, settings and startup link deleted.")
EndFunc


;; Boundaries ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func _GetBoundaries()
	; for the constants see https://msdn.microsoft.com/en-us/library/windows/desktop/ms724385(v=vs.85).aspx
	Local $SM_CXVIRTUALSCREEN = _
		DllCall("user32.dll", "int", "GetSystemMetrics", "int", 78)[0]
	Local $SM_CYVIRTUALSCREEN = _
		DllCall("user32.dll", "int", "GetSystemMetrics", "int", 79)[0]
	Local $SM_XVIRTUALSCREEN = _
		DllCall("user32.dll", "int", "GetSystemMetrics", "int", 76)[0]
	Local $SM_YVIRTUALSCREEN = _
		DllCall("user32.dll", "int", "GetSystemMetrics", "int", 77)[0]

	; Boundaries of the virtual screen
	Global $X_MIN = $SM_XVIRTUALSCREEN
	Global $X_MAX = $SM_CXVIRTUALSCREEN + $SM_XVIRTUALSCREEN - 1
	Global $Y_MIN = $SM_YVIRTUALSCREEN
	Global $Y_MAX = $SM_CYVIRTUALSCREEN + $SM_YVIRTUALSCREEN - 1
EndFunc

;; Main Loop ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Current mouse position
Global $Pos[2]

While 1
	If $DisabledInfiniMouse = False Then
		_GetBoundaries()

		$Pos = MouseGetPos()
		$X = $Pos[0]
		$Y = $Pos[1]

		If $EnableLeftBorder And $Pos[0] = $X_MIN Then
			DllCall("user32.dll", "bool", "SetCursorPos", "int", $X_MAX - 1, "int", $Y)
		EndIf

		If $EnableRightBorder And $Pos[0] = $X_MAX Then
			DllCall("user32.dll", "bool", "SetCursorPos", "int", $X_MIN + 1, "int", $Y)
		EndIf

		If $EnableTopBorder And $Pos[1] = $Y_MIN Then
			DllCall("user32.dll", "bool", "SetCursorPos", "int", $X, "int", $Y_MAX - 1)
		EndIf

		If $EnableBottomBorder And $Pos[1] = $Y_MAX Then
			DllCall("user32.dll", "bool", "SetCursorPos", "int", $X, "int", $Y + 1)
		EndIf

	EndIf
	Sleep($Delay)
WEnd
