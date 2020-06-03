## dotfiles.ps1
## michael@mwild.me

[CmdletBinding()]
param(
    [String][ValidateSet('Build','Clean')] $Action,
	[String] $Path,
    [Switch] $Help
)
process {
    $ErrorActionPreference = 'Stop'

    Write-Host "-.. --- - ..-. .. .-.. . ..." -ForegroundColor cyan # dotfiles morse code
    if (($Help) -or !($Action)) {
        Write-Host 'creates symlinks for your dotfiles'
        Write-Host 'usage: dotfiles [-action] <action> [-path <path_to_data_directory>]'
        Write-Host ''
        Write-Host '  -Action   Build (create symlinks), Clean (remove symlinks)'
        Write-Host '  -Path     Path to data directory (default: .\data)'
        Write-Host ''
        return
    }

    if (!$Path) { $Path = (Join-Path $PSScriptRoot 'data') }

    $config = Get-Content -Path (Join-Path $Path 'dotfiles.json') -Raw | ConvertFrom-Json

    foreach ($dotfile in $config.symlinks | Where-Object enabled) {
        Write-Host "`n• $($dotfile.name)"

        $dotfile.link = [System.Environment]::ExpandEnvironmentVariables($dotfile.link)
        $dotfile.link = $ExecutionContext.InvokeCommand.ExpandString($dotfile.link)

        if ($Action -eq 'Clean') {
            if (!(Test-Path $dotfile.link)) {
                Write-Host "  $($dotfile.link) already clean"
            } else {
                Write-Host "  Removing $($dotfile.link)"

                Remove-Item -Path $dotfile.link
            }
        } elseif ($Action -eq 'Build') {
            $dotfileLinkDir = Split-Path $dotfile.link
            if (-not (Test-Path $dotfileLinkDir)) { 
                New-Item -ItemType Directory -Path $dotfileLinkDir | Out-Null 
            }

            $dotfile.target = Join-Path $Path $dotfile.target

            Write-Host "  $($dotfile.link)`n  -> $($dotfile.target)"

            New-Item -ItemType SymbolicLink -Path $dotfile.link -Target $dotfile.target | Out-Null
        }
    }
}