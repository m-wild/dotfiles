﻿## posh-rcm.ps1
## powershell .*rc manager
## michael@mwild.me

[CmdletBinding()]
#Requires -Version 3
param(
    [Switch]$Build,
    [Switch]$Clean,
    [Switch]$Rebuild,
    [Switch]$Help,
    [String]$Path
)
process 
{  
    try 
    {
        # includes
        . "$PSScriptRoot\..\lib\secutil.ps1"
        . "$PSScriptRoot\..\lib\symlink.ps1"
        
        $pattern_target = "target="
        $pattern_link = "link="
		
		$ascii_logo = 
@"
             _                     
 ___ ___ ___| |_ ___ ___ ___ _____ 
| . | . |_ -|   |___|  _|  _|     |
|  _|___|___|_|_|   |_| |___|_|_|_|
|_|     
"@

		Write-Host $ascii_logo -ForegroundColor Cyan
		
		
		# handle -Rebuild switch
		if ($Rebuild)
		{
			$Clean = $true
			$Build = $true
		}
		
		     
        # usage information
        if ((!$Build -and !$Clean) -or ($Help))
        {
            Write-Host "Powershell rc manager"
            Write-Host "Creates symlinks for your .*rc files"
            Write-Host "usage:"	-NoNewLine -ForegroundColor Yellow
				   Write-Host " posh-rcm" -NoNewLine
							 Write-Host " [-Build] [-Clean] [-Rebuild] [-Path <path_to_data_directory>]" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  -Build    create symlinks as defined in data\*\_conf"
            Write-Host "  -Clean    remove existing symlinks"
            Write-Host "  -Rebuild  alias for -Clean -Build"
            Write-Host "  -Path     path to data directory (default: .\data)"

            if (!$Help) 
            {
                Write-Host "  -Help     display additional help"
            }
            else 
            {
                Write-Host "  -Help     display this text"
                Write-Host ""
				Write-Host "Help:" -ForegroundColor Yellow
                Write-Host "Place any scripts you want managed in their own folder under \data"
                Write-Host "Add a _conf file with the following content:"
                Write-Host "  $pattern_target<your_rc_script>"
                Write-Host "  $pattern_link<the_link_to_create>"
                Write-Host "Then run:"
                Write-Host "  posh-rcm -Build"
                Write-Host ""
                Write-Host "To update existing files:"
                Write-Host "  posh-rcm -Rebuild"
            }

            Write-Host ""
            return
        }


        # we need to be admin for mklink to work
        if ($Build) 
        {
            $admin = Test-IsAdmin
            if (!$admin) 
            {
                Write-Host "-Build requires elevated privileges" -ForegroundColor Red -BackgroundColor Black
                return
            }
        }
    
        # use the default path if not provided
        if (!$Path)
        {
            $Path = "$PSScriptRoot\..\data\"
        }

        foreach ($module in Get-ChildItem -Path $Path) 
        {
            Write-Host "scanning directory data\$($module.Name)..." -ForegroundColor Green

            # find all directories with conf       
            $conf = Get-ChildItem -Path $module.FullName -Filter "_conf"
            if (!$conf) 
            {
                Write-Host "_conf missing for $($module.Name) ...skipping" -ForegroundColor Yellow
            }
            else
            {
                # read the conf file
                $target = $null
                $target = (Select-String -Path $conf -Pattern $pattern_target).Line
				if (!$target)
				{
					throw "Pattern not found : '$pattern_target'"
				}
                $target = $target.Substring($pattern_target.Length)
                $target = Join-Path -path $module.FullName -ChildPath $target
                $target = [System.Environment]::ExpandEnvironmentVariables($target)
                $target = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($target)
            
                $link = $null
                $link = (Select-String -Path $conf -Pattern $pattern_link).Line
                if (!$link)
                {
                    throw "Pattern not found : '$pattern_link'"
                }
                $link = $link.Substring($pattern_link.Length)
                $link = [System.Environment]::ExpandEnvironmentVariables($link)
                $link = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($link)
            
                # remove existing
                if ($Clean) 
                {
					Write-Host ">> cleaning module $($module.Name)..."
					
                    if (-not (Test-Path -Path $link)) 
                    {
                        Write-Host "$link already clean"
                    }
                    else 
                    {
                        Write-Host "removing file $($link)"
                        remove-item -Path $link
                    }
                }

                # create the symlink
                if ($Build) 
                {
					Write-Host ">> creating symlink..."
                    
					Write-Host "target = $target"
                    Write-Host "link = $link"

                    # create the link directory structure if it doesn't already exist
                    $link_dir = Split-Path -Path $link
                    if (-not (Test-Path -Path $link_dir))
                    {
                        # swallow the output into $res
                        $res = New-Item -Path $link_dir -ItemType Directory
                    }
                    
                    New-Symlink -Target $target -Link $link
                }
            }

            Write-Host ""
        }
    
    }
    catch
    {
        # rethrow - we just want to make sure we fail completely on the first error
        throw
    }
}
