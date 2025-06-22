#!/usr/bin/env pwsh

# Import shared installation helpers
$helpersPath = Join-Path $PSScriptRoot 'Private\InstallationHelpers.ps1'
if (Test-Path $helpersPath) {
    . $helpersPath
} else {
    throw "InstallationHelpers.ps1 not found at: $helpersPath"
}

<#
.SYNOPSIS
    Installs the VideoFunctions PowerShell module.

.DESCRIPTION
    This script installs the VideoFunctions module to the appropriate PowerShell modules directory.
    It supports both Windows PowerShell and PowerShell Core, and can install for the current user
    or for all users (requires elevation).

.PARAMETER Scope
    Specifies the installation scope. Valid values are 'CurrentUser' and 'AllUsers'.
    Default is 'CurrentUser'. 'AllUsers' requires elevation.

.PARAMETER Force
    Forces the installation even if the module already exists.

.PARAMETER Verbosity
    Controls the level of messages displayed. Valid values are 'Silent', 'Error', 'Warning', 'Info', 'Success', and 'All'.
    Default is 'All'. 'Silent' suppresses all messages except errors, 'Error' shows only errors,
    'Warning' shows warnings and errors, 'Info' shows info, warnings, and errors, 'Success' shows all except debug,
    and 'All' shows all message types.

.PARAMETER WhatIf
    Shows what would happen if the script runs without actually performing the installation.

.PARAMETER Confirm
    Prompts for confirmation before performing the installation.

.EXAMPLE
    .\Install-VideoFunctions.ps1

    Installs the module for the current user.

.EXAMPLE
    .\Install-VideoFunctions.ps1 -Scope AllUsers

    Installs the module for all users (requires elevation).

.EXAMPLE
    .\Install-VideoFunctions.ps1 -Force

    Forces installation even if the module already exists.

.EXAMPLE
    .\Install-VideoFunctions.ps1 -WhatIf

    Shows what would happen without actually installing.

.EXAMPLE
    .\Install-VideoFunctions.ps1 -Verbosity Silent

    Installs the module with minimal output (errors only).

.EXAMPLE
    .\Install-VideoFunctions.ps1 -Verbosity Warning

    Installs the module showing only warnings and errors.

.NOTES
    This script should be run from the directory containing the VideoFunctions module.
    For AllUsers installation, the script must be run with administrative privileges.
#>

# Suppress linter warnings for dot-sourced enums
# The enums are imported from InstallationHelpers.ps1
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $false)]
    [InstallScope]$Scope = [InstallScope]::CurrentUser,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [VerbosityLevel]$Verbosity = [VerbosityLevel]::All
)

# Set strict error handling
$ErrorActionPreference = 'Stop'

# Main installation logic
try {
    Write-InstallationMessage "Starting VideoFunctions module installation..." 'Info' $Verbosity
    Write-InstallationMessage "PowerShell Version: $($PSVersionTable.PSVersion)" 'Info' $Verbosity
    Write-InstallationMessage "PowerShell Edition: $($PSVersionTable.PSEdition)" 'Info' $Verbosity
    Write-InstallationMessage "Installation Scope: $Scope" 'Info' $Verbosity
    
    # Check if running from the correct directory
    if (-not (Test-ModuleStructure -VerbosityLevel $Verbosity)) {
        throw "Current directory does not contain a valid VideoFunctions module structure. Please run this script from the VideoFunctions module directory."
    }
    
    # Check for administrative privileges if installing for all users
    if ($Scope -eq 'AllUsers' -and -not (Test-Administrator)) {
        throw "Administrative privileges are required to install for all users. Please run PowerShell as Administrator or use -Scope CurrentUser."
    }
    
    # Get installation path
    $installPath = Get-ModuleInstallPath -Scope $Scope
    $modulePath = Join-Path $installPath 'VideoFunctions'
    
    Write-InstallationMessage "Installation path: $modulePath" 'Info' $Verbosity
    
    # Check if module already exists
    if (Test-Path $modulePath) {
        if ($Force) {
            Write-InstallationMessage "Module already exists. Force flag specified, will overwrite existing installation." 'Warning' $Verbosity
        } else {
            throw "Module already exists at '$modulePath'. Use -Force to overwrite or -Scope CurrentUser to install for current user only."
        }
    }
    
    # Get current module version
    $moduleVersion = Get-ModuleVersion -VerbosityLevel $Verbosity
    Write-InstallationMessage "Installing VideoFunctions version $moduleVersion" 'Info' $Verbosity
    
    # Perform the installation
    if ($PSCmdlet.ShouldProcess($modulePath, "Install VideoFunctions module")) {
        # Create the module directory if it doesn't exist
        if (-not (Test-Path $installPath)) {
            Write-InstallationMessage "Creating modules directory: $installPath" 'Info' $Verbosity
            New-Item -Path $installPath -ItemType Directory -Force | Out-Null
        }
        
        # Copy the module files
        Write-InstallationMessage "Copying module files to: $modulePath" 'Info' $Verbosity
        Copy-Item -Path '.' -Destination $modulePath -Recurse -Force
        
        # Verify the installation
        if (Test-Path $modulePath) {
            Write-InstallationMessage "Module files copied successfully." 'Success' $Verbosity
            
            # Test module import
            Write-InstallationMessage "Testing module import..." 'Info' $Verbosity
            try {
                Import-Module $modulePath -Force -ErrorAction Stop
                $importedFunctions = Get-Command -Module VideoFunctions
                Write-InstallationMessage "Module imported successfully. Found $($importedFunctions.Count) functions." 'Success' $Verbosity
                
                # Show available functions
                Write-InstallationMessage "Available functions:" 'Info' $Verbosity
                foreach ($function in $importedFunctions) {
                    Write-InstallationMessage "  - $($function.Name)" 'Info' $Verbosity
                }
                
                # Remove the module to clean up
                Remove-Module VideoFunctions -Force -ErrorAction SilentlyContinue
                
            } catch {
                Write-InstallationMessage "Module import test failed: $($_.Exception.Message)" 'Error' $Verbosity
                throw
            }
            
        } else {
            throw "Failed to copy module files to $modulePath"
        }
    }
    
    Write-InstallationMessage "Installation completed successfully!" 'Success' $Verbosity
    Write-InstallationMessage "To use the module, run: Import-Module VideoFunctions" 'Info' $Verbosity
    
    # Show usage examples
    Write-InstallationMessage "Example usage:" 'Info' $Verbosity
    Write-InstallationMessage "  Import-Module VideoFunctions" 'Info' $Verbosity
    Write-InstallationMessage "  Get-Command -Module VideoFunctions" 'Info' $Verbosity
    Write-InstallationMessage "  Get-Help Get-FFMpegVersion" 'Info' $Verbosity
    
} catch {
    Write-InstallationMessage "Installation failed: $($_.Exception.Message)" 'Error' $Verbosity
    exit 1
} 