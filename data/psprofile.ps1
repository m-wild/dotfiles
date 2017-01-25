## powershell profile
## michael@mwild.me

$global:ssh_public_id  = join-path $env:ssh_key_directory "id_rsa.pub"
$global:ssh_private_id = join-path $env:ssh_key_directory "id_rsa.ppk"
$global:log_path       = join-path $env:user_home ".logs"

new-alias dotfiles "$env:user_tools_path\dotfiles\dotfiles.ps1"

# linux sugar
new-alias vi code
new-alias open start
new-alias grep Select-String
new-alias touch New-Item
function ll { Get-ChildItem -Force $args }
function which { (Get-Command -All $args).Definition }
function tail ([switch]$f,$path) { if ($f) { Get-Content -Path $path -Tail 10 -Wait } else { Get-Content -Path $path -Tail 10 } }
new-alias dig "$env:programfiles\ISC BIND 9\bin\dig.exe"  # dont wan't every BIND tool in PATH.. just dig

# widows stuff
function mklink { cmd.exe /c mklink $args }
function reset-color { [Console]::ResetColor() }
function edit-hosts { start-process notepad -verb runas -ArgumentList @( "$env:windir\system32\drivers\etc\hosts" ) }
function reset-netadapter { ipconfig /release $args; ipconfig /flushdns; ipconfig /renew $args }
function add-path {
    $env:path += ";$args"
    [Environment]::SetEnvironmentVariable("Path", $env:path + ";$args", [EnvironmentVariableTarget]::Machine)
}
function format-json { $args | convertfrom-json | convertto-json }

# ssh/scp/ssl
function ssh { putty $args -new_console }  # note: -new_console is for conemu
function ssh-agent {
    push-location
    set-location $env:systemroot  # pageant locks the folder that it starts in so start it in systemroot
    pageant $global:ssh_private_id 
    pop-location
}
function ssh-copy-id {
    $cred = get-credential
    get-content $global:ssh_public_id | plink $args -l $cred.username -pw $cred.getNetworkCredential().password 'umask 077; test -d .ssh || mkdir .ssh; cat >> .ssh/authorized_keys'
}
new-alias winscp "${env:programfiles(x86)}\WinSCP\winscp.exe"
new-alias openssl "$env:programfiles\openssl\bin\openssl.exe"

# web
new-alias chrome "${env:programfiles(x86)}\Google\Chrome\Application\chrome.exe"
new-alias firefox "${env:programfiles(x86)}\Mozilla Firefox\firefox.exe"
function google { chrome "https://www.google.co.nz/search?q=$args" }

# code/build
new-alias git-tf "$env:user_tools_path\git-tf\git-tf.cmd"
new-alias msbuild-v140 "${env:programfiles(x86)}\MSBuild\14.0\Bin\MSBuild.exe"
new-alias msbuild msbuild-v140
function __vstsuri { ((git remote -v)[0] -split "`t" -split " ")[1] }
function open-vsts { chrome "$(__vstsuri)/" }
function new-pullreq { chrome "$(__vstsuri)/pullrequestcreate?sourceRef=$(git symbolic-ref --short HEAD)&targetRef=master" }

# vanity
function get-sysinfo {
    $os   = Get-WmiObject Win32_OperatingSystem
    $proc = Get-WmiObject Win32_Processor
    $sys  = Get-WmiObject Win32_ComputerSystem
    $gpu  = Get-WmiObject Win32_DisplayConfiguration

    $ram = "$([math]::round($sys.totalPhysicalMemory / 1GB))GB"

    write-host $os.caption $os.osarchitecture $os.version
    write-host $proc.name $ram
    write-host $gpu.devicename
}


function test-isadmin {  # test if the current shell is elevated
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}


Set-Variable HOME $env:user_home -Force  			 # Set and force overwrite of the $HOME variable
(get-psprovider 'FileSystem').Home = $env:user_home  # set the "~" shortcut

# custom prompt w/ logging
$global:prompt_prev_dir = Get-Location
$global:prompt_prev_hist_id = 0
$global:prompt_log_file = Join-Path $global:log_path "\shell-history-$(get-date -f 'yyyy-MM').log"
function prompt {
    $hist = Get-History -Count 1
    if ($hist.Id -gt $global:prompt_prev_hist_id) {  # log new entries only
        add-content -path $global:prompt_log_file -value "$($hist.StartExecutionTime.toString('yyyy-MM-dd.HH:mm:ss')) $pid [$global:prompt_prev_path] $($hist.CommandLine)"
    }
    $global:prompt_prev_hist_id = $hist.Id

    $cd = Get-Location
    $global:prompt_prev_path = $cd

    # pretty print prompt
    if (test-isadmin) {
        $host.UI.RawUI.WindowTitle = "[Admin] $cd"
        write-host "[$(split-path $cd -leaf)]" -NoNewLine
        write-host "#" -NoNewLine -ForegroundColor red  # supposed to return it, but then we cant get ~color~
        return " "
    } else {
        $host.UI.RawUI.WindowTitle = "$cd"
        return "[$(split-path $cd -leaf)]$ "
    }
}

if (test-isadmin) { Set-Location ~ }  # we need to do this manually..
