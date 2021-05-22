# powershell profile
# michael@mwild.me

# Environment variables need to be set:
#  SSH_KEY_DIRECTORY
#

# Linux command aliases
Set-PSReadlineKeyHandler -Key Tab -Function Complete # make tab work like bash

New-Alias open Start-Process -Force
New-Alias touch New-Item -Force
function ll { Get-ChildItem -Force $Args }
function which { (Get-Command -All $Args).Definition }
function tail ([switch]$f,$Path) { if ($f) { Get-Content -Path $Path -Tail 10 -Wait } else { Get-Content -Path $Path -Tail 10 } }
function lc { Measure-Object -Line }


# Windows stuff
function mklink { cmd.exe /c mklink $Args }
function Reset-Color { [Console]::ResetColor() }
function Edit-Hosts { start-process notepad -verb runas -ArgumentList @( "$env:WINDIR\system32\drivers\etc\hosts" ) }
function Edit-Env { rundll32 sysdm.cpl,EditEnvironmentVariables }
function Reset-NetAdapter { ipconfig /release $Args; ipconfig /flushdns; ipconfig /renew $Args }


# Data-Type Conversions
function Format-Json { $Args | ConvertFrom-Json | ConvertTo-Json }
function ConvertTo-Base64 { 
    param([Parameter(ValueFromPipeline=$true)] $Value)
    $Value | ForEach-Object{ $b = [System.Text.Encoding]::UTF8.GetBytes($_); [System.Convert]::ToBase64String($b); }
}
function ConvertFrom-Base64 {
    param ([Parameter(ValueFromPipeline=$true)] $Value)
    $Value | ForEach-Object{ $b = [System.Convert]::FromBase64String($_); [System.Text.Encoding]::UTF8.GetString($b); }
}

function Write-SHA1Hash ($Path) { (Get-FileHash -Algorithm SHA1 $Path).Hash > "$Path.sha1" }

## SSH
function Get-SshPublicKey {
    Get-Content -Path (Join-Path $env:SSH_KEY_DIRECTORY "id_ed25519.pub")
}
function Copy-SshPublicKey {
    Get-SshPublicKey | ssh $Args 'umask 077; test -d .ssh || mkdir .ssh; cat >> .ssh/authorized_keys'
}
New-Alias ssh-copy-id Copy-SshPublicKey -Force



## Code/Build
new-alias MSBuild "${env:programfiles(x86)}\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" -Force

function __azdevops-repo-url { "https://dev.azure.com/vocusgroupnz/vocus/_git/" + (git remote get-url origin).split('/')[-1] }
function Open-AZDevOps { open "$(__azdevops-repo-url)/" }
function New-PullRequest { open "$(__azdevops-repo-url)/pullrequestcreate?sourceRef=$(git symbolic-ref --short HEAD)&targetRef=master" }
New-Alias pr New-PullRequest -Force

function git-deploy {
    [CmdletBinding()]
    param (
        [Switch] $force,
        [String] $branch = 'dev'
    ) 
    process {
        $ErrorActionPreference = 'Stop'

        $current_branch = git rev-parse --abbrev-ref HEAD; 
        Write-Host "• Pushing current branch ($current_branch)..." -ForegroundColor Blue
        git fetch
        git push

        if ($Force) {
            Write-Host "• Reset $branch to $current_branch..." -ForegroundColor Blue
            git branch -D $branch
            git checkout $branch
            git reset --hard $current_branch

            Write-Host "• Force push $branch" -ForegroundColor Blue
            git push -f

        } else {
            Write-Host "• Merge $branch to $current_branch..." -ForegroundColor Blue
            git branch -D $branch
            git checkout $branch
            git reset --hard origin/$branch
            git merge $current_branch

            if ($LASTEXITCODE -eq 0) {
                Write-Host "• Push $branch" -ForegroundColor Blue
                git push
            } else {
                Write-Host "• Merge conflicts must be resolved" -ForegroundColor Yellow
            }

        }
            
        git checkout $current_branch
    }
}

function Copy-AZDevOpsRepo ($repo) {
    & git clone "https://vocusgroupnz@dev.azure.com/vocusgroupnz/Vocus/_git/$repo"
}
New-Alias clone Copy-AZDevOpsRepo -Force


function git-switch() {
    $branches =  git branch $args | ` # args allows passing '--all' for example
        rg --invert-match '\*' | ` # remove the currently selected branch
        %{ $_.trim() } | ` # remove whitespace from start of line
        where { $_ -notlike '*->*' } | ` # remove the 'HEAD -> master' line...
        %{ if ($_.startsWith('remotes/origin/')) { $_.substring('remotes/origin/'.length) } else { $_ }  } | ` # show remote branches as if local
        select -unique # we may have a remote and local copy of a branch, only show one


    $branch = (echo $branches | fzf)
    if ($branch) {
        git switch $branch
    }
}


function git-delete-branches() {
    $branches = git branch | `
        rg --invert-match '\*' | ` # remove the currently selected branch
        %{ $_.trim() } | ` # remove whitespace from start of line
        fzf --multi --preview="git lg {} --color"

    if ($branches) {
        echo $branches | %{ git branch --delete --force $_ }
    }
}




# dotnet-suggest shim
if (test-path $env:USERPROFILE\.dotnet\tools\.store\dotnet-suggest) {
    $dotnetSuggestShim = Get-ChildItem -Path $env:USERPROFILE\.dotnet\tools\.store\dotnet-suggest -recurse -filter "dotnet-suggest-shim.ps1" | Select-Object -first 1
    if (Test-Path $dotnetSuggestShim.FullName) {
        . $dotnetSuggestShim.FullName
    }
}


function rider {
    $rider_dir = Join-Path $env:LOCALAPPDATA "JetBrains\Toolbox\apps\Rider\ch-0" | Get-ChildItem | Where-Object mode -Like 'd*' | Where-Object name -NotLike '*.plugins' | Sort-Object | Select-Object -Last 1
    $rider_path = Join-Path $rider_dir "bin\rider64.exe"
    Start-Process $rider_path -ArgumentList @( $Args )
}

function Open-Solution {
    [CmdletBinding()]
    param (
        [String] $Path = (Get-Location),
        [Switch] $VS
    )
    process {
        $solutions = Get-ChildItem -Filter *.sln -Path $Path -Depth 3

        if ($solutions.count -eq 0) {
            Write-Host "No solutions found..."
            return
        } elseif ($solutions.count -eq 1) {
            $sln = $solutions | Select-Object -First 1
        } else {
            $choices = @()
            for ($i = 0; $i -lt $solutions.count; $i++) {
                $s = $solutions[$i]
                $choices += New-Object System.Management.Automation.Host.ChoiceDescription "&$i $($s.Name)", $s.FullName
            }

            $choiceindex = $host.ui.PromptForChoice("", "Multiple solutions found...", $choices, 0)
            $sln = $solutions[$choiceindex]
        }
        
        Write-Host "Opening solution $($sln.Name)"
        if ($VS) {
            open $sln.FullName
        } else {
            rider $sln.FullName
        }
    }
}
New-Alias sln Open-Solution -Force

## vanity
function Get-SysInfo {
    $os   = Get-WmiObject Win32_OperatingSystem
    $proc = Get-WmiObject Win32_Processor
    $sys  = Get-WmiObject Win32_ComputerSystem
    $gpu  = Get-WmiObject Win32_DisplayConfiguration

    $ram = "$([math]::round($sys.TotalPhysicalMemory / 1GB))GB"

    Write-Host $os.Caption $os.OSArchitecture $os.Version
    Write-Host $proc.Name $ram
    Write-Host $gpu.DeviceName
}

function Test-IsAdmin {  # test if the current shell is elevated
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}



# custom prompt w/ logging
$global:prompt_prev_dir     = Get-Location
$global:prompt_prev_hist_id = 0
$global:prompt_log_path     = Join-Path $env:USERPROFILE ".logs\shell-history-$(Get-Date -Format 'yyyy-MM').log"

function prompt {
    # Write command history to the log
	$prev_LASTEXITCODE = $LASTEXITCODE
    $hist = Get-History -Count 1
    if ($hist.Id -gt $global:prompt_prev_hist_id) {  # log new entries only
        Add-Content -Path $global:prompt_log_path -Value "$($hist.StartExecutionTime.toString('yyyy-MM-dd.HH:mm:ss')) $pid [$global:prompt_prev_path] $($hist.CommandLine)"
    }

    $global:prompt_prev_hist_id = $hist.Id
    $global:prompt_prev_path = Get-Location
   
    $prompt = ""
    # Use posh-git prompt if available
    if ((Get-Command 'Write-VcsStatus' -ErrorAction SilentlyContinue) `
            -And (Get-Command 'git.exe' -ErrorAction SilentlyContinue)) {
        $prompt += & $GitPromptScriptBlock
    }
    
    else {
        $prompt += "[$(Get-Location | Split-Path -Leaf)]$ "
    }
    
	$LASTEXITCODE = $prev_LASTEXITCODE
    return $prompt
}

if (Test-IsAdmin) { Set-Location ~ }  # we need to do this manually..

# have to do this after setting the prompt or we get the default posh-git prompt
Import-Module posh-git
$global:GitPromptSettings.DefaultPromptPrefix = "["
$global:GitPromptSettings.DefaultPromptSuffix = "]$ "
$global:GitPromptSettings.BeforeStatus = ""
$global:GitPromptSettings.AfterStatus = ""
$global:GitPromptSettings.DefaultPromptPath = '$(Get-Location | Split-Path -Leaf)'
