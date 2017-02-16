; mwil.ahk
; michael@mwild.me

; minimize (instead of restore)
#Down::WinMinimize, A

; shell
^!PgDn::
	Run, "%programfiles%\ConEmu\ConEmu64.exe" -run {powershell}
	Sleep, 500
	WinActivate, ahk_exe conemu64.exe
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

; (F19) nothing...
; Vk82::
