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

#include <File.au3>
#include <TrayConstants.au3>
#include <MsgBoxConstants.au3>

Opt("TrayOnEventMode", 1)
Opt("TrayMenuMode", 3)
Opt("TrayAutoPause", 0)


;; Tray Menu ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

$MenuItemLeftBorder = TrayCreateItem("Left border")
TrayItemSetOnEvent(-1, "MenuItemEvent")
$MenuItemRightBorder = TrayCreateItem("Right border")
TrayItemSetOnEvent(-1, "MenuItemEvent")
$MenuItemTopBorder = TrayCreateItem("Top border")
TrayItemSetOnEvent(-1, "MenuItemEvent")
$MenuItemBottomBorder = TrayCreateItem("Bottom border")
TrayItemSetOnEvent(-1, "MenuItemEvent")
TrayCreateItem("") ; separator
$MenuItemDisabled = TrayCreateItem("Disabled")
TrayItemSetOnEvent(-1, "MenuItemEvent")
TrayCreateItem("") ; separator
$MenuItemRestart = TrayCreateItem("Restart")
TrayItemSetOnEvent(-1, "MenuItemEvent")
TrayCreateItem("") ; separator
$MenuItemExit = TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "MenuItemEvent")
TraySetIcon("shell32.dll", -239)
TraySetToolTip("InfiniMouse")


;; Settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Global Const $SETTINGS_DIR_PATH = @AppDataDir	 & "\InfiniMouse"
Global $SETTINGS_INI_PATH = $SETTINGS_DIR_PATH & "\settings.ini"
If DirCreate($SETTINGS_DIR_PATH) == 0 Then MsgBox($MB_SYSTEMMODAL, "Error", $SETTINGS_DIR_PATH & " couldn't be created.")

Global $DisabledInfiniMouse = False

ReadSettings()

Func ReadSettings()
   ; IniRead() and IniWrite() doesn't work with booleans
   Global $EnableLeftBorder = _
     "true" = IniRead($SETTINGS_INI_PATH, "borders", "left", "true")
   Global $EnableRightBorder = _
     "true" = IniRead($SETTINGS_INI_PATH, "borders", "right", "true")
   Global $EnableTopBorder = _
     "true" = IniRead($SETTINGS_INI_PATH, "borders", "top", "false")
   Global $EnableBottomBorder = _
     "true" = IniRead($SETTINGS_INI_PATH, "borders", "bottom", "false")


   TrayItemSetState($MenuItemLeftBorder, _
      $EnableLeftBorder ? $TRAY_CHECKED : $TRAY_UNCHECKED)
   TrayItemSetState($MenuItemRightBorder, _
      $EnableRightBorder ? $TRAY_CHECKED : $TRAY_UNCHECKED)
   TrayItemSetState($MenuItemTopBorder, _
      $EnableTopBorder ? $TRAY_CHECKED : $TRAY_UNCHECKED)
   TrayItemSetState($MenuItemBottomBorder, _
      $EnableBottomBorder ? $TRAY_CHECKED : $TRAY_UNCHECKED)
   TrayItemSetState($MenuItemDisabled, _
      $DisabledInfiniMouse ? $TRAY_CHECKED : $TRAY_UNCHECKED)

   Global $Delay = IniRead($SETTINGS_INI_PATH, "general", "delay", 20)
EndFunc


;; Tray Menu Events ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func MenuItemEvent()
   Switch (@TRAY_ID)
      Case $MenuItemLeftBorder
         IniWrite($SETTINGS_INI_PATH, "borders", "left", _
	    $EnableLeftBorder ? "false" : "true")
      Case $MenuItemRightBorder
         IniWrite($SETTINGS_INI_PATH, "borders", "right", _
	    $EnableRightBorder ? "false" : "true")
      Case $MenuItemTopBorder
         IniWrite($SETTINGS_INI_PATH, "borders", "top", _
	    $EnableTopBorder ? "false" : "true")
      Case $MenuItemBottomBorder
         IniWrite($SETTINGS_INI_PATH, "borders", "bottom", _
	    $EnableBottomBorder ? "false" : "true")
	 Case $MenuItemRestart
		 _Restart()
	 Case $MenuItemDisabled
		 $DisabledInfiniMouse = $DisabledInfiniMouse == False ? True : False
	  Case $MenuItemExit
         Exit
   EndSwitch
   ReadSettings()
EndFunc

Func _Restart()
   Run(@ScriptFullPath)
   exit
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

; Current mouse position
Global $Pos[2]

While 1
	If $DisabledInfiniMouse == False Then
		_GetBoundaries()

	   $Pos = MouseGetPos ()
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
