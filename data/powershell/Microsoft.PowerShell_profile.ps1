## powershell profile
## michael@mwild.me

#### aliases
# powershell native
new-alias open start
new-alias grep Select-String
new-alias gch Get-ChildItem
new-alias touch New-Item
function ll ($params)  { ls -Force $params }

# emulation of linux "which"
function which ($com) { (Get-Command -All $com).Definition }

# alias of linux "tail" with "-f" switch implemented
function tail ([switch]$f,$file) {  if ($f) { Get-Content $file -Tail 10 -Wait } else { Get-Content $file -Tail 10 } }

# useful for cleaning up after nodejs for example
function reset-color { [Console]::ResetColor() }

# isc bind
new-alias dig "C:\Program Files\ISC BIND 9\bin\dig.exe"

# editors
new-alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"
new-alias vim "C:\Program Files (x86)\vim\vim74\vim.exe"
new-alias vi vim
new-alias less "C:\Program Files (x86)\GnuWin32\bin\less.exe"

# ssh (putty)
new-alias putty "C:\Program Files (x86)\PuTTY\putty.exe"
new-alias ssh putty
new-alias plink 'C:\Program Files (x86)\PuTTY\plink.exe'

# media
new-alias youtube-dl "C:\Program Files (x86)\youtube-dl\youtube-dl.exe"
new-alias ffmpeg "C:\Program Files\ffmpeg\bin\ffmpeg.exe"

####
# set a new "home" directory
$h = "G:\downloads"
cd $h


