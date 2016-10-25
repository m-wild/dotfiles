## powershell profile
## michael@mwild.me

# set globals from environment 
$global:ssh_public_id = join-path $env:ssh_key_directory "id_rsa.pub"
$global:ssh_private_id = join-path $env:ssh_key_directory "id_rsa.ppk"
$global:log_home = join-path $env:user_home ".logs"


# util
new-alias open start
new-alias grep Select-String
new-alias gch Get-ChildItem
new-alias touch New-Item
function ll ($params)  { ls -Force $params }
function reset-color { [Console]::ResetColor() }
function which ($com) { (Get-Command -All $com).Definition }
function tail ([switch]$f,$file) {  if ($f) { Get-Content $file -Tail 10 -Wait } else { Get-Content $file -Tail 10 } }
new-alias ps-admin "d:\michael.wildman\tools\powershell-michaelw-admin.lnk"
function edit-hosts { start-process notepad -verb runas -ArgumentList @( "$($env:windir)\system32\drivers\etc\hosts" ) }
function format-json { $args | convertfrom-json | convertto-json }
new-alias fjson format-json
function reset-netadapter { ipconfig /release $args; ipconfig /flushdns; ipconfig /renew $args }


# editors
new-alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"
new-alias vi subl
new-alias bcomp "$($env:programfiles)\beyond compare 4\bcomp.exe"

# ssh
new-alias putty "C:\Program Files (x86)\PuTTY\putty.exe"
new-alias plink "C:\Program Files (x86)\PuTTY\plink.exe"
new-alias pageant "C:\Program Files (x86)\PuTTY\pageant.exe"
function ssh { putty $args -new_console }
function ssh-agent { pageant $global:ssh_private_id }
function ssh-copy-id {
	$cred = get-credential
	get-content $global:ssh_public_id | plink $args -l $cred.username -pw $cred.getNetworkCredential().password 'umask 077; test -d .ssh || mkdir .ssh; cat >> .ssh/authorized_keys'
}
new-alias winscp "C:\Program Files (x86)\WinSCP\winscp.exe"
new-alias openssl "c:\program files\openssl\bin\openssl.exe"

# web
new-alias chrome "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
new-alias firefox "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
function google { chrome "https://www.google.co.nz/search?q=$args" }

# code/build
new-alias nuget "D:\michael.wildman\tools\NuGet\nuget.exe"
new-alias tf "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\TF.exe"
new-alias tfpt "C:\Program Files (x86)\Microsoft Team Foundation Server 2015 Power Tools\TFPT.exe"
new-alias msbuild-v140 "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
new-alias msbuild msbuild-v140
new-alias git-tf "D:\michael.wildman\tools\git-tf\git-tf.cmd"

# python
new-alias py "C:\Windows\py.exe"
new-alias python "c:\python\3\python.exe"
new-alias pip "c:\python\3\Scripts\pip.exe"

# media
new-alias youtube-dl "C:\Program Files (x86)\youtube-dl\youtube-dl.exe"
new-alias ffmpeg "C:\Program Files\ffmpeg\bin\ffmpeg.exe"
new-alias ffprobe "C:\Program Files\ffmpeg\bin\ffprobe.exe"
new-alias ffplay "C:\Program Files\ffmpeg\bin\ffplay.exe"

# other
new-alias conemu "C:\Program Files\ConEmu\ConEmu64.exe"
new-alias dig "C:\Program Files\ISC BIND 9\bin\dig.exe"
new-alias splunk "C:\Program Files\Splunk\bin\Splunk.exe"


# test if the current shell is elevated
function test-isadmin {
	return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}


# set initial "previous" directory
$global:promptPrevDir = (pwd)
$global:promptPrevHistLength = 0


# set a new "home" directory
# Set and force overwrite of the $HOME variable
Set-Variable HOME $env:user_home -Force

# Set the "~" shortcut value for the provider
(get-psprovider 'FileSystem').Home = $env:user_home


# custom prompt
function prompt {
	$isAdmin = test-isadmin
	$cd = (pwd)

	# log previous command to file
	# only if the history has a new command added
	if ((h).length -gt $global:promptPrevHistLength) {
		add-content -path "$($global:log_home)/shell-history-$(get-date -f 'yyyy-MM').log" `
			-value "$((h)[-1].StartExecutionTime.toString('yyyy-MM-dd.HH:mm:ss')) $pid [$global:promptPrevDir] $((h)[-1].commandLine)"
		$global:promptPrevHistLength = (h).length
	}
	$global:promptPrevDir = $cd

	# pretty print prompt
	if ($isAdmin) {
		$host.UI.RawUI.WindowTitle = "Admin: $cd"
		write-host "[$(split-path $cd -leaf)]" -noNewLine
		write-host "#" -noNewLine -foregroundColor red
	} else {
		$host.UI.RawUI.WindowTitle = "$cd"
		write-host "[$(split-path $cd -leaf)]$" -noNewLine
	}
	return " "
}
