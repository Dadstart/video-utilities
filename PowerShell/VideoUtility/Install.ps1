<#
.SYNOPSIS
    Install script for the VideoUtility PowerShell module.

.DESCRIPTION
    This script installs the VideoUtility PowerShell module to the user's PowerShell modules directory.
    It will create the necessary directory structure and copy all module files.

.PARAMETER Force
    Force installation even if the module already exists.

.EXAMPLE
    .\Install.ps1
    
    Installs the VideoUtility module to the user's PowerShell modules directory.

.EXAMPLE
    .\Install.ps1 -Force
    
    Forces installation, overwriting any existing installation.

.NOTES
    This script requires PowerShell 7.0 or higher.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

#Requires -Version 7.0

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Determine the target modules directory
$modulesPath = if ($IsWindows) {
    Join-Path $env:USERPROFILE 'Documents\PowerShell\Modules'
}
else {
    Join-Path $HOME '.local/share/powershell/Modules'
}

# Create modules directory if it doesn't exist
if (-not (Test-Path $modulesPath)) {
    Write-Verbose "Creating modules directory: $modulesPath"
    New-Item -Path $modulesPath -ItemType Directory -Force | Out-Null
}

# Define the target module directory
$targetModulePath = Join-Path $modulesPath 'VideoUtility'

# Check if module already exists
if (Test-Path $targetModulePath) {
    if ($Force) {
        Write-Verbose 'Removing existing module installation'
        Remove-Item -Path $targetModulePath -Recurse -Force
    }
    else {
        Write-Warning "Module already exists at: $targetModulePath"
        Write-Warning 'Use -Force parameter to overwrite existing installation'
        return
    }
}

try {
    # Copy module files
    Write-Verbose "Installing VideoUtility module to: $targetModulePath"
    Copy-Item -Path $scriptDir -Destination $targetModulePath -Recurse -Force
    
    # Verify installation
    if (Test-Path (Join-Path $targetModulePath 'VideoUtility.psd1')) {
        Write-Host 'VideoUtility module installed successfully!' -ForegroundColor Green
        Write-Host "Module location: $targetModulePath" -ForegroundColor Cyan
        
        # Test module import
        Write-Verbose 'Testing module import'
        Import-Module VideoUtility -Force -ErrorAction Stop
        Write-Host 'Module import test successful!' -ForegroundColor Green
        
        # Show available functions
        $functions = Get-Command -Module VideoUtility
        if ($functions) {
            Write-Host 'Available functions:' -ForegroundColor Yellow
            $functions | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
        }
        
        Write-Host "`nTo use the module, run: Import-Module VideoUtility" -ForegroundColor Cyan
    }
    else {
        throw 'Module manifest not found after installation'
    }
}
catch {
    Write-Error "Failed to install VideoUtility module: $($_.Exception.Message)"
    throw
} 