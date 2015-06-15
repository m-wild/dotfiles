## powershell profile
## michael@mwild.me

# module
Import-Module PsGet
Import-Module PsReadLine

# alias
New-Alias ll ls
New-Alias open start
New-Alias grep Select-String
New-Alias gch Get-ChildItem
New-Alias dig "C:\Program Files\BIND\dig.exe"
New-Alias lame "C:\Program Files\lame\lame.exe"
New-Alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"
New-Alias vi npp
New-Alias putty "C:\Program Files (x86)\PuTTY\putty.exe"
New-Alias ssh putty

# func
function which ($com) { (Get-Command -All $com).Definition }
function tail ($file) { Get-Content $file -Tail 10 -Wait }


# home
$h = "G:\downloads"
cd $h
