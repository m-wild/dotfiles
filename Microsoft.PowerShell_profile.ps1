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
New-Alias dig "C:\Program Files\ISC BIND 9\bin\dig.exe"
#New-Alias lame "C:\Program Files\lame\lame.exe"
New-Alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"
New-Alias vi npp
New-Alias putty "C:\Program Files (x86)\PuTTY\putty.exe"
New-Alias ssh putty
New-Alias svcutil "C:\Program Files (x86)\Microsoft SDKs\Windows\v8.1A\bin\NETFX 4.5.1 Tools\SvcUtil.exe"
New-Alias installutil "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\installutil.exe"




# func
function which ($com) { (Get-Command -All $com).Definition }
function tail ($file) { Get-Content $file -Tail 10 -Wait }


# home
$h = "D:\downloads"
cd $h
