; mwil.ahk
; michael@mwild.me

; Session options
SetTitleMatchMode, 2

; minimize (instead of restore)
#Down::WinMinimize, A

; shell
^!PgDn::
	EnvGet, home, user_home
	Run, powershell.exe, %home%
	return

; (F7-F12) media key
#F7::SendInput {Media_Prev}
#F8::SendInput {Media_Play_Pause}
#F9::SendInput {Media_Next}
#F10::SendInput {Volume_Mute}
#F11::SendInput {Volume_Down}
#F12::SendInput {Volume_Up}

; (F13)
VK7c::SendInput {PrintScreen}
^VK7c::SendInput ^{PrintScreen}

; (F14)
VK7d::SendInput {ScrollLock}

; (F15)
Vk7e::SendInput {Pause}

; (F16) Toggle NVIDIA Share
Vk7f::SendInput ^!{PgUp}

; (F17) Save NVIDIA Shadow recording
Vk80::SendInput !{F10}

; (F18)
Vk81::SendInput {Insert}
!Vk81::SendInput !{Insert}
^Vk81::SendInput ^{Insert}
^!Vk81::SendInput ^!{Insert}

; (F19) Cycle default audio playback device
Vk82::
	Run, mmsys.cpl
	WinWait, Sound
	ControlSend, SysListView321, {Down}
	ControlGet, isEnabled, Enabled, , &Set Default
	if(!isEnabled)
	{
	  ControlSend, SysListView321, {Down 2}
	}
	ControlClick, &Set Default
	ControlClick, OK
	WinWaitClose
	SoundPlay, *-1
	return
