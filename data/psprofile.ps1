## powershell profile
## michael@mwild.me

$global:ssh_public_id  = join-path $env:ssh_key_directory "id_rsa.pub"
$global:log_path       = join-path $env:user_home ".logs"

new-alias dotfiles "$env:user_tools_path\dotfiles\dotfiles.ps1" -force

## linux sugar
new-alias vi code -force
new-alias open start -force
new-alias grep Select-String -force
new-alias touch New-Item -force
function ll { Get-ChildItem -Force $args }
function which { (Get-Command -All $args).Definition }
function tail ([switch]$f,$path) { if ($f) { Get-Content -Path $path -Tail 10 -Wait } else { Get-Content -Path $path -Tail 10 } }
new-alias dig "$env:programfiles\ISC BIND 9\bin\dig.exe" -force # dont wan't every BIND tool in PATH.. just dig
function mdc { mkdir $args[0]; cd $args[0]; }
Set-PSReadlineKeyHandler -Key Tab -Function Complete # make tab work like bash
function lc { measure-object -line }

## widows stuff
function mklink { cmd.exe /c mklink $args }
function reset-color { [Console]::ResetColor() }
function edit-hosts { start-process notepad -verb runas -ArgumentList @( "$env:windir\system32\drivers\etc\hosts" ) }
function edit-env { rundll32 sysdm.cpl,EditEnvironmentVariables }
function reset-netadapter { ipconfig /release $args; ipconfig /flushdns; ipconfig /renew $args }
function add-path {
    # update the saved env
    $userpath = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User).Split(';');
    $userpath[-1] = $args[0]
    $newpath = [String]::Join(";", $userpath) + ";"
    Write-Host "User %PATH% will be set to $newpath"
    [Environment]::SetEnvironmentVariable("PATH", $newpath, [EnvironmentVariableTarget]::User)

    # also update the current process env
    $env:path += $args[0] + ";"
}
function format-json { $args | convertfrom-json | convertto-json }

# script to wrap restic using windows credential store
new-alias restic "$env:user_tools_path\restic\restic.ps1" -force

## ssh/scp/ssl/rdp
function ssh-copy-id {
    get-content $global:ssh_public_id | ssh $args 'umask 077; test -d .ssh || mkdir .ssh; cat >> .ssh/authorized_keys'
}
function copy-sshpublickey {
    get-content $global:ssh_public_id | clip
}

## web
new-alias chrome "${env:programfiles(x86)}\Google\Chrome Beta\Application\chrome.exe" -force
new-alias firefox "${env:programfiles(x86)}\Mozilla Firefox\firefox.exe" -force

## code/build
new-alias git-tf "$env:user_tools_path\git-tf\git-tf.cmd" -force
new-alias msbuild14 "${env:programfiles(x86)}\MSBuild\14.0\Bin\MSBuild.exe" -force
new-alias msbuild15 "${env:programfiles(x86)}\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe" -force
new-alias msbuild msbuild15 -force
new-alias nuget451 "$env:user_tools_path\nuget\4.5.1.4879\nuget.exe" -force
new-alias nuget nuget451 -force
new-alias vstest "${env:programfiles(x86)}\Microsoft Visual Studio\2017\Professional\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe" -force

function __azdevopsuri { "https://dev.azure.com/vocusgroupnz/vocus/_git/" + (git remote get-url origin).split('/')[-1] }
function open-azdevops { chrome "$(__azdevopsuri)/" }
function new-pullrequest { chrome "$(__azdevopsuri)/pullrequestcreate?sourceRef=$(git symbolic-ref --short HEAD)&targetRef=master" }
function git-cleanall { git checkout -- .; git clean -dfx; git checkout master; git pull }
function remove-buildartifacts { gci -recurse | where name -in bin,obj | rm -recurse -force }
function git-pushdev { $branch = git rev-parse --abbrev-ref HEAD; git push; git checkout dev; git reset --hard $branch; git push -f; git checkout $branch; }

# discover and run dotnet unit tests
function dotnet-unittest ([switch]$build) {
    if ($build) {
        $sln = (gci *.sln)[0]
        msbuild /t:rebuild /v:minimal /m $sln
    }
    $tested = @()
    $tests = gci -Recurse | where { `
        $_.directoryname -ilike '*bin\debug*' `
        -and $_.name -ilike '*test*.dll' `
        -and $_.name -inotlike '*testadapter*' `
    }
    foreach ($t in $tests) {
        if ($tested -icontains $t.name) { continue }
        $tested += $t.name
        vstest /parallel /testcasefilter:"TestCategory!=Integration" $t.fullname
    }
}

function rider {
    $rider_path = "$env:localappdata\JetBrains\Toolbox\apps\Rider\ch-0"
    $rider_version = ls $rider_path | where mode -like 'd*' | sort | select -last 1
    start-process "$rider_path\$rider_version\bin\rider64.exe" -ArgumentList @( $args )
}
function open-solution ([string] $path, [switch] $rider) {
    if (!$path) {
        $path = get-location
    }

    $allslns = gci -filter *.sln -Path $path -Depth 3

    if ($allslns.count -eq 1) {
        $sln = $allslns | select -first 1
    } else {
        $choices = @()
        for ($i = 0; $i -lt $allslns.count; $i++) {
            $s = $allslns[$i]
            $choices += New-Object System.Management.Automation.Host.ChoiceDescription "&$i $($s.Name)", $s.FullName
        }

        $choiceindex = $host.ui.PromptForChoice("", "Multiple solutions found...", $choices, 0)
        $sln = $allslns[$choiceindex]
    }
    
    write-host "Opening solution $($sln.Name)"
    if ($rider) {
        rider $sln.FullName
    } else {
        open $sln.FullName
    }
}

## Logging
function get-logs ([string]$app, [switch]$formatted, [switch]$this, [string]$path) {
	if ($this) {
        $app = (split-path (pwd) -leaf)
    }
	if ($app) {
        $date = get-date -Format 'yyyyMMdd'
		$path = "$env:app_logs\$app\$app.$date.log"
	}
	    
    if ($formatted) {
        _getlogformatted -path $path
    } else {
        _getlogjson -path $path
    }
}
function _getlogjson ($path) {
    get-content -tail 0 -wait -path $path | %{convertfrom-json $_} 
}
function _getlogformatted ($path) { 
    _getlogjson $path | select timestamp,severity,message,exception | %{
        if ($_.severity -in "error","fatal") {
            _writelogformatted $_ "red"
        } elseif ($_.severity -eq "warn") {
            _writelogformatted $_ "yellow"
        } elseif ($_.severity -in "trace","debug","verbose") {
            _writelogformatted $_ "darkgray"
        } else {
            _writelogformatted $_ "gray"
        }
    }
}
function _writelogformatted ($log, $color) { 
    write-host $log.timestamp.substring(11) $log.severity.padright(5) $log.message $log.exception -ForegroundColor $color 
}

## vanity
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

# z.ps https://github.com/JannesMeyer/z.ps
if (test-path "$env:HOMEDRIVE\$env:HOMEPATH\Documents\WindowsPowerShell\Modules\z") {
    import-module z
    set-alias z search-navigationhistory -force
}

# custom prompt w/ logging
$global:prompt_prev_dir = Get-Location
$global:prompt_prev_hist_id = 0
$global:prompt_log_file = Join-Path $global:log_path "\shell-history-$(get-date -f 'yyyy-MM').log"

function prompt {
	$prev_LASTEXITCODE = $LASTEXITCODE
    $hist = Get-History -Count 1
    if ($hist.Id -gt $global:prompt_prev_hist_id) {  # log new entries only
        add-content -path $global:prompt_log_file -value "$($hist.StartExecutionTime.toString('yyyy-MM-dd.HH:mm:ss')) $pid [$global:prompt_prev_path] $($hist.CommandLine)"
    }
    $global:prompt_prev_hist_id = $hist.Id

    $cd = Get-Location
    $global:prompt_prev_path = $cd

    # update z.ps
    if (get-command 'update-navigationhistory' -erroraction SilentlyContinue) {
        update-navigationhistory $pwd.Path -erroraction silentlycontinue
    }

    write-host "[$(split-path $cd -leaf)" -NoNewLine

    # print git info
    if ((get-command 'write-vcsstatus' -erroraction SilentlyContinue)  `
        -and (get-command 'git.exe' -erroraction SilentlyContinue)) {
        write-vcsstatus
    }
    
	write-host "]" -NoNewLine

    # pretty print prompt
    if (test-isadmin) {
        $host.UI.RawUI.WindowTitle = "[Admin] $cd"
        write-host "#" -NoNewLine -ForegroundColor red  
    } else {
        $host.UI.RawUI.WindowTitle = "$cd"
        write-host "$" -NoNewline
    }

	$LASTEXITCODE = $prev_LASTEXITCODE
    return " " # supposed to return the prompt string, but then we cant get ~color~
}

if (test-isadmin) { Set-Location ~ }  # we need to do this manually..

# have to do this after setting the prompt or we get the default posh-git prompt
import-module posh-git 
$global:GitPromptSettings.BeforeText = ' '
$global:GitPromptSettings.AfterText = ''
