## powershell profile
## michael@mwild.me

# alias
New-Alias open start
New-Alias grep Select-String
New-Alias gch Get-ChildItem
New-Alias dig "C:\Program Files\BIND\dig.exe"
New-Alias lame "C:\Program Files\lame\lame.exe"
New-Alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"
New-Alias putty "C:\Program Files (x86)\PuTTY\putty.exe"
New-Alias ssh putty
New-Alias plink 'C:\Program Files (x86)\PuTTY\plink.exe'
New-Alias less "C:\Program Files (x86)\GnuWin32\bin\less.exe"
New-Alias youtube-dl "C:\Program Files (x86)\youtube-dl\youtube-dl.exe"
New-Alias ffmpeg "C:\Program Files\ffmpeg\bin\ffmpeg.exe"
New-Alias ffprobe "C:\Program Files\ffmpeg\bin\ffprobe.exe"


# func
function ll { ls -force }
function which ($com) { (Get-Command -All $com).Definition }
function tail ($file) { Get-Content $file -Tail 10 -Wait }


# home
$h = "G:\downloads"
cd $h
