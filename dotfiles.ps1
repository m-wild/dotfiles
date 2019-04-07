## dotfiles.ps1
## michael@mwild.me

[CmdletBinding()]
param(
    [string][validateset("build","clean")] $action,
	[string] $path,
    [switch] $help
)
process {
    $ErrorActionPreference = "stop"

    function Test-IsDirectory ($Path) { return (Get-Item -Path $Path).PSIsContainer }

    write-host "-.. --- - ..-. .. .-.. . ..." -foregroundColor cyan # dotfiles morse code
    if (($Help) -or !($action)) {
        write-host "creates symlinks for your dotfiles"
        write-host "usage: dotfiles [-action] <action> [-path <path_to_data_directory>]"
        write-host ""
        write-host "  -action   build (create symlinks), clean (remove symlinks)" 
        write-host "  -path     path to data directory (default: .\data)"
        write-host ""
        return
    }

    if (!$path) { $path = (join-path $PSScriptRoot "data") }

    $config = get-content -path (join-path $path "dotfiles.json") -raw | convertfrom-json

    # --- 1. symlinks
    foreach ($dotfile in $config.symlink | where enabled) {
        write-host "`n>> $($dotfile.name)"

        $dotfile.link = [System.Environment]::ExpandEnvironmentVariables($dotfile.link)
        $dotfile.link = $ExecutionContext.InvokeCommand.ExpandString($dotfile.link)
    
        if ($action -eq "clean") {
            if (!(test-path $dotfile.link)) {
                write-host "$($dotfile.link) already clean"
            } else {
                write-host "removing link $($dotfile.link)"

                # this is a quirk of trying to delete directory symlinks in powershell
                if (Test-IsDirectory $dotfile.link) {
                    cmd.exe /c rmdir $dotfile.link
                } else {
                    remove-item -Path $dotfile.link
                }
            }
        } 
        elseif ($action -eq "build") {
            $dotfile_linkDir = split-path $dotfile.link
            if (-not (test-path $dotfile_linkDir)) { mkdir $dotfile_linkDir | out-null }

            $dotfile.target = Join-Path $path $dotfile.target
            
            # we have to tell mklink if the target is a directory
            if (Test-IsDirectory $dotfile.target) { 
                cmd.exe /c mklink /d $dotfile.link $dotfile.target
            } else {
                cmd.exe /c mklink $dotfile.link $dotfile.target
            }
        }
    }
}