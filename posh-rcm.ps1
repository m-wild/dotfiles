## posh-rcm.ps1
## powershell .*rc manager
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
    
    $logo =
@"
             _                     
 ___ ___ ___| |_ ___ ___ ___ _____ 
| . | . |_ -|   |___|  _|  _|     |
|  _|___|___|_|_|   |_| |___|_|_|_|
|_|     
"@
    Write-Host $logo -ForegroundColor Cyan
    
    # usage information
    if (($Help) -or !($action -in "build", "clean")) {
        Write-Host "Powershell rc manager"
        Write-Host "Creates symlinks for your rc files"
        Write-Host "usage: posh-rcm [-action] <action> [-Path <path_to_data_directory>]"
        Write-Host ""
        Write-Host "  -action   build (create symlinks), clean (remove symlinks)" 
        Write-Host "  -path     path to data directory (default: .\data)"
        Write-Host ""
        return
    }

    # we need to be admin for mklink to work
    if (($action -eq "build") -and !(Test-IsAdmin)) { throw "Build requires elevated privileges" }

    # use the default path if not provided
    if (!$path) { $path = "$PSScriptRoot\data\" }

    $config = get-content -path (join-path $path "prcm.json") -raw | convertfrom-json

    foreach ($module in $config.modules) {
        Write-Host ""
        Write-Host ">> $($module.name)"

        $module.linkFile = Join-Path $path $module.linkFile
        $module.linkFile = [System.Environment]::ExpandEnvironmentVariables($module.linkFile)
        $module.linkFile = $ExecutionContext.InvokeCommand.ExpandString($module.linkFile)
      
        $module.linkTo = [System.Environment]::ExpandEnvironmentVariables($module.linkTo)
        $module.linkTo = $ExecutionContext.InvokeCommand.ExpandString($module.linkTo)
    
        # remove existing
        if ($action -eq "clean") {
            if (!(Test-Path $module.linkTo)) {
                Write-Host "$($module.linkTo) already clean"
            } else {
                Write-Host "removing link $($module.linkTo)"
                remove-item -Path $module.linkTo
            }
        } 
        # create symlinks
        elseif ($action -eq "build") {
            # create the link directory structure if it doesn't already exist
            $module_linkToDir = split-path $module.linkTo
            if (-not (Test-Path $module_linkToDir)) { mkdir $module_linkToDir > $null }
            
            New-Symlink -Target $module.linkFile -Link $module.linkTo
        }
    }
}