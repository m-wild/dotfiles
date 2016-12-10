## dotfiles.ps1
## michael@mwild.me

[CmdletBinding()]
#Requires -Version 3
param(
	[string]$action,
	[string]$path,
    [switch]$help
)
process 
{
    $ErrorActionPreference = "stop"

    # includes
    . "$PSScriptRoot\lib\secutil.ps1"
    . "$PSScriptRoot\lib\symlink.ps1"

    write-host "-.. --- - ..-. .. .-.. . ..." -foregroundColor cyan # dotfiles morse code
    
    # usage information
    if (($Help) -or !($action -in "build", "clean")) {
        write-host "creates symlinks for your dotfiles"
        write-host "usage: dotfiles [-action] <action> [-path <path_to_data_directory>]"
        write-host ""
        write-host "  -action   build (create symlinks), clean (remove symlinks)" 
        write-host "  -path     path to data directory (default: .\data)"
        write-host ""
        return
    }

    # we need to be admin for mklink to work
    if (($action -eq "build") -and !(test-isAdmin)) { throw "build requires elevated privileges" }

    # use the default path if not provided
    if (!$path) { $path = (join-path $PSScriptRoot "data") }

    $config = get-content -path (join-path $path "dotfiles.json") -raw | convertfrom-json

    # --- 1. symlinks
    foreach ($dotfile in $config.symlink | where enabled) {
        write-host ""
        write-host ">> $($dotfile.name)"

        $dotfile.linkFile = Join-Path $path $dotfile.linkFile

        # expand linkTo variables
        $dotfile.linkTo = [System.Environment]::ExpandEnvironmentVariables($dotfile.linkTo)
        $dotfile.linkTo = $ExecutionContext.InvokeCommand.ExpandString($dotfile.linkTo)
    
        # remove existing
        if ($action -eq "clean") {
            if (!(test-path $dotfile.linkTo)) {
                write-host "$($dotfile.linkTo) already clean"
            } else {
                write-host "removing link $($dotfile.linkTo)"
                remove-item -Path $dotfile.linkTo
            }
        } 
        # create symlinks
        elseif ($action -eq "build") {
            # create the link directory structure if it doesn't already exist
            $dotfile_linkToDir = split-path $dotfile.linkTo
            if (-not (test-path $dotfile_linkToDir)) { mkdir $dotfile_linkToDir > $null }
            
            new-symlink -Target $dotfile.linkFile -Link $dotfile.linkTo
        }
    }

    # --- 2. registry keys
    foreach ($reg in $config.reg | where enabled) {
        write-host ""
        write-host ">> $($reg.name)"

        $reg.importPath = Join-Path $path $reg.importPath

        # remove existing reg keys
        if ($action -eq "clean") {
            if (!(test-path $reg.cleanPath)) {
                write-host "$($reg.cleanPath) already clean"
            } else {
                write-host "removing registry keys $($reg.cleanPath)"
                remove-item -Recurse -Path $reg.cleanPath
            }
        }
        # import reg file
        elseif ($action -eq "build") {
            write-host "importing reg $($reg.importPath)... " -nonewline
            & reg import $reg.importPath
        }
    }

}