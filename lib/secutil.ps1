## secutil.psm1
## security related utilites
## michael@mwild.me



function Test-IsAdmin {
    <#
    .SYNOPSIS
        Checks if the current powershell instance is running with elevated privileges
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param()
    process {
        ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
}