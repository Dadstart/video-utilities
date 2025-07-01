<#
.SYNOPSIS
    Install script for the VideoUtility PowerShell module.

.DESCRIPTION
    This script installs the VideoUtility PowerShell module by importing it from the current directory.

.PARAMETER Force
    Force installation even if the module is already loaded.

.EXAMPLE
    .\Install.ps1
    
    Installs the VideoUtility module by importing it from the current directory.

.EXAMPLE
    .\Install.ps1 -Force
    
    Forces installation, reloading the module even if already loaded.

.NOTES
    This script requires PowerShell 7.0 or higher.
    The module will be loaded from its current directory location for this session only.
#>

[CmdletBinding()]
param(
    [switch]$Force
)

#Requires -Version 7.0

# Get the script directory (module root)
$moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Verify this is a valid module directory
$manifestPath = Join-Path $moduleRoot 'VideoUtility.psd1'
if (-not (Test-Path $manifestPath)) {
    Write-Error "Module manifest not found at: $manifestPath"
    Write-Error "Please run this script from the VideoUtility module directory."
    throw 'Invalid module directory'
}

# Check if module is already loaded
$isAlreadyLoaded = Get-Module -Name VideoUtility -ErrorAction SilentlyContinue -Verbose:$Verbose

if ($isAlreadyLoaded -and -not $Force) {
    Write-Warning "VideoUtility module is already loaded"
    Write-Warning 'Use -Force parameter to reload the module'
    
    Write-Host 'VideoUtility module is already available!' -ForegroundColor Green
    Write-Host "Module location: $moduleRoot" -ForegroundColor Cyan
    
    return
}

try {
    # Import the module
    Write-Verbose 'Importing VideoUtility module'
    $modulePath = Join-Path $moduleRoot 'VideoUtility'
    Import-Module $modulePath -Force:$Force -ErrorAction Stop -Verbose:$VerbosePreference
    Write-Host 'VideoUtility module installed successfully!' -ForegroundColor Green
    Write-Verbose "Module location: $moduleRoot"
}
catch {
    Write-Error "Failed to install VideoUtility module: $($_.Exception.Message)"
    throw
} 