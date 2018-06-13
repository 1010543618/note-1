^!c::
ifwinexist Cmder
{
	winactivate
	;send cd /c/codes{enter}
}
else
{
	run C:\Devtools\Cmder\Cmder.exe
}
return

!a::
if WinExist("ahk_exe chrome.exe")
{
	WinActivate, ahk_exe chrome.exe
}
return

!d::
if WinExist("ahk_exe code.exe")
{
	WinActivate, ahk_exe code.exe
}
return

!s::
if WinExist("ahk_exe firefox.exe")
{
	WinActivate, ahk_exe firefox.exe
}
return

!r::
{
	if WinActive("ahk_exe Code.exe")
	{
		send {F1}trut{Down}{Enter}
	}
}

#c::
MouseGetPos, mouseX, mouseY
; 获得鼠标所在坐标，把鼠标的 X 坐标赋值给变量 mouseX ，同理 mouseY
PixelGetColor, color, %mouseX%, %mouseY%, RGB
; 调用 PixelGetColor 函数，获得鼠标所在坐标的 RGB 值，并赋值给 color
StringRight color,color,6
; 截取 color（第二个 color）右边的6个字符，因为获得的值是这样的：#RRGGBB，一般我们只需要 RRGGBB 部分。把截取到的值再赋给 color（第一个 color）。
clipboard = `#%color%
; 把 color 的值发送到剪贴板
return

#IfWinActive Cmder  ; if in emacs
+Capslock::Capslock ; make shift+Caps-Lock the Caps Lock toggle
Capslock::Control   ; make Caps Lock the control button
#IfWinActive        ; end if in emacs