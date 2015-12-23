## powershell profile
## michael@mwild.me

# alias and functions
New-Alias open start
New-Alias grep Select-String
New-Alias gch Get-ChildItem
New-Alias dig "C:\Program Files\ISC BIND 9\bin\dig.exe"
New-Alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"
New-Alias putty "C:\Program Files (x86)\PuTTY\putty.exe"
New-Alias ssh putty
New-Alias plink "C:\Program Files (x86)\PuTTY\plink.exe"
#New-Alias less "C:\Program Files (x86)\GnuWin32\bin\less.exe"
New-Alias tf "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\TF.exe"

function which ($com) { (Get-Command -All $com).Definition }
function tail ([switch]$f,$file) {  Get-Content $file -Tail 10 -Wait }
function ll { ls -Force }
function reset-color { [Console]::ResetColor() }

# home
$h = "D:\michael.wildman"
cd $h

