<#
.SYNOPSIS
    Install script for the VideoUtility PowerShell module.

.DESCRIPTION
    This script installs the VideoUtility PowerShell module by adding the current directory
    to the PowerShell module path, allowing the module to be loaded from its current location.

.PARAMETER Force
    Force installation even if the module path is already configured.

.EXAMPLE
    .\Install.ps1
    
    Installs the VideoUtility module by adding the current directory to PSModulePath.

.EXAMPLE
    .\Install.ps1 -Force
    
    Forces installation, reconfiguring the module path even if already set.

.NOTES
    This script requires PowerShell 7.0 or higher.
    The module will be loaded from its current directory location.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
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

# Get the parent directory (where the module folder is located)
$parentDir = Split-Path -Parent $moduleRoot

# Check if the parent directory is already in PSModulePath
$currentModulePath = $env:PSModulePath -split ';'
$isAlreadyConfigured = $currentModulePath -contains $parentDir

if ($isAlreadyConfigured -and -not $Force) {
    Write-Warning "Module path is already configured: $parentDir"
    Write-Warning 'Use -Force parameter to reconfigure the module path'
    
    # Test if module can be imported
    try {
        Import-Module VideoUtility -Force -ErrorAction Stop
        Write-Host 'VideoUtility module is already available!' -ForegroundColor Green
        Write-Host "Module location: $moduleRoot" -ForegroundColor Cyan
        
        # Show available functions
        $functions = Get-Command -Module VideoUtility
        if ($functions) {
            Write-Host 'Available functions:' -ForegroundColor Yellow
            $functions | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
        }
        
        return
    }
    catch {
        Write-Warning "Module path is configured but module cannot be imported: $($_.Exception.Message)"
    }
}

try {
    # Add the parent directory to PSModulePath for the current session
    $env:PSModulePath = "$parentDir;$env:PSModulePath"
    
    # Add to user's PowerShell profile for persistence
    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileDir = Split-Path -Parent $profilePath
    
    # Create profile directory if it doesn't exist
    if (-not (Test-Path $profileDir)) {
        Write-Verbose "Creating profile directory: $profileDir"
        New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
    }
    
    # Read existing profile content
    $profileContent = if (Test-Path $profilePath) {
        Get-Content -Path $profilePath -Raw
    } else {
        ''
    }
    
    # Check if the module path is already in the profile
    $modulePathLine = "`$env:PSModulePath = `"$parentDir;`$env:PSModulePath`""
    if ($profileContent -notlike "*$parentDir*") {
        # Add the module path to the profile
        $newContent = if ($profileContent.Trim()) {
            "$profileContent`n# VideoUtility module path`n$modulePathLine"
        } else {
            "# VideoUtility module path`n$modulePathLine"
        }
        
        Set-Content -Path $profilePath -Value $newContent -Encoding UTF8
        Write-Verbose "Added module path to profile: $profilePath"
    }
    
    # Test module import
    Write-Verbose 'Testing module import'
    Import-Module VideoUtility -Force -ErrorAction Stop
    Write-Host 'VideoUtility module installed successfully!' -ForegroundColor Green
    Write-Host "Module location: $moduleRoot" -ForegroundColor Cyan
    Write-Host "Module path added: $parentDir" -ForegroundColor Cyan
    
    # Show available functions
    $functions = Get-Command -Module VideoUtility
    if ($functions) {
        Write-Host 'Available functions:' -ForegroundColor Yellow
        $functions | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
    }
    
    Write-Host "`nThe module is now available in this session and will be available in future sessions." -ForegroundColor Cyan
    Write-Host "To use the module, run: Import-Module VideoUtility" -ForegroundColor Cyan
}
catch {
    Write-Error "Failed to install VideoUtility module: $($_.Exception.Message)"
    throw
} 