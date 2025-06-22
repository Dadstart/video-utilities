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
    Reinstalls the VideoFunctions PowerShell module.

.DESCRIPTION
    This script performs a complete reinstallation of the VideoFunctions module by:
    1. Saving the current directory
    2. Navigating to the VideoFunctions module directory
    3. Uninstalling the module (passing through all parameters)
    4. Installing the module (passing through all parameters)
    5. Restoring the original directory

    This is useful for updating the module or fixing installation issues.

.PARAMETER Scope
    Specifies the installation/uninstallation scope. Valid values are 'CurrentUser', 'AllUsers', and 'All'.
    Default is 'All' for uninstall and 'CurrentUser' for install. 'AllUsers' requires elevation.

.PARAMETER Force
    Forces the reinstallation without prompting for confirmation.
    When specified, this parameter bypasses all confirmation prompts.

.PARAMETER Verbosity
    Controls the level of messages displayed. Valid values are 'Silent', 'Error', 'Warning', 'Info', 'Success', and 'All'.
    Default is 'All'. 'Silent' suppresses all messages except errors, 'Error' shows only errors,
    'Warning' shows warnings and errors, 'Info' shows info, warnings, and errors, 'Success' shows all except debug,
    and 'All' shows all message types.

.PARAMETER ImportModule
    Automatically imports the VideoFunctions module after successful installation.
    This is useful for immediate use of the module or testing the installation.

.PARAMETER WhatIf
    Shows what would happen if the script runs without actually performing the reinstallation.

.PARAMETER Confirm
    Prompts for confirmation before performing the reinstallation.
    Note: Due to the high impact nature of this operation, confirmation may still be required
    unless -Force is specified.

.EXAMPLE
    .\Reinstall-VideoFunctions.ps1

    Reinstalls the module using default settings.

.EXAMPLE
    .\Reinstall-VideoFunctions.ps1 -Scope AllUsers -Force

    Reinstalls the module for all users without prompting for confirmation.

.EXAMPLE
    .\Reinstall-VideoFunctions.ps1 -Verbosity Silent

    Reinstalls the module with minimal output (errors only).

.EXAMPLE
    .\Reinstall-VideoFunctions.ps1 -WhatIf

    Shows what would happen without actually reinstalling.

.EXAMPLE
    .\Reinstall-VideoFunctions.ps1 -ImportModule

    Reinstalls the module and automatically imports it for immediate use.

.EXAMPLE
    .\Reinstall-VideoFunctions.ps1 -Force -ImportModule

    Reinstalls the module without prompts and imports it automatically.

.NOTES
    This script can be run from any directory.
    For AllUsers reinstallation, the script must be run with administrative privileges.
    The script will automatically navigate to the VideoFunctions module directory and restore the original directory.
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $false)]
    [ReinstallScope]$Scope = [ReinstallScope]::All,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [VerbosityLevel]$Verbosity = [VerbosityLevel]::All,
    
    [Parameter(Mandatory = $false)]
    [switch]$ImportModule
)

# Set strict error handling
$ErrorActionPreference = 'Stop'

# Main reinstallation logic
try {
    Write-InstallationMessage "Starting VideoFunctions module reinstallation..." 'Info' $Verbosity
    Write-InstallationMessage "PowerShell Version: $($PSVersionTable.PSVersion)" 'Info' $Verbosity
    Write-InstallationMessage "PowerShell Edition: $($PSVersionTable.PSEdition)" 'Info' $Verbosity
    Write-InstallationMessage "Reinstallation Scope: $Scope" 'Info' $Verbosity
    
    # Save current directory
    $originalDirectory = Get-Location
    Write-InstallationMessage "Original directory: $originalDirectory" 'Info' $Verbosity
    
    # Check for administrative privileges if needed
    if ($Scope -eq 'AllUsers' -and -not (Test-Administrator)) {
        throw "Administrative privileges are required to reinstall for all users. Please run PowerShell as Administrator or use -Scope CurrentUser."
    }
    
    # Find VideoFunctions directory
    $videoFunctionsDir = Find-VideoFunctionsDirectory
    if (-not $videoFunctionsDir) {
        throw "VideoFunctions module directory not found. Please ensure this script is run from or near the VideoFunctions module directory."
    }
    
    Write-InstallationMessage "Found VideoFunctions directory: $videoFunctionsDir" 'Info' $Verbosity
    
    # Navigate to VideoFunctions directory
    Write-InstallationMessage "Navigating to VideoFunctions directory..." 'Info' $Verbosity
    Set-Location $videoFunctionsDir
    
    # Build parameter hashtables
    $uninstallParams = Build-UninstallParameters -Scope $Scope -Force $Force -Verbosity $Verbosity -WhatIfPreference $WhatIfPreference -ConfirmPreference $ConfirmPreference
    $installParams = Build-InstallParameters -Scope $Scope -Force $Force -Verbosity $Verbosity -WhatIfPreference $WhatIfPreference -ConfirmPreference $ConfirmPreference
    
    Write-InstallationMessage "Uninstall parameters: $($uninstallParams | ConvertTo-Json -Compress)" 'Info' $Verbosity
    Write-InstallationMessage "Install parameters: $($installParams | ConvertTo-Json -Compress)" 'Info' $Verbosity
    
    # Perform the reinstallation
    $shouldProceed = $false
    
    if ($Force) {
        # When -Force is specified, bypass confirmation
        $shouldProceed = $true
    } else {
        # Use ShouldProcess for confirmation handling
        $shouldProceed = $PSCmdlet.ShouldProcess("VideoFunctions module", "Reinstall")
    }
    
    if ($shouldProceed) {
        # Step 1: Uninstall
        Write-InstallationMessage "Step 1: Uninstalling VideoFunctions module..." 'Info' $Verbosity
        $uninstallScript = Join-Path $videoFunctionsDir 'Uninstall-VideoFunctions.ps1'
        
        if (-not (Test-Path $uninstallScript)) {
            throw "Uninstall script not found at: $uninstallScript"
        }
        
        Write-InstallationMessage "Executing uninstall script with parameters: $($uninstallParams | ConvertTo-Json -Compress)" 'Info' $Verbosity
        
        # Execute uninstall script with parameters
        $uninstallResult = & $uninstallScript @uninstallParams
        $uninstallExitCode = $LASTEXITCODE
        
        if ($uninstallExitCode -ne 0) {
            throw "Uninstall failed with exit code: $uninstallExitCode"
        }
        
        Write-InstallationMessage "Uninstall completed successfully." 'Success' $Verbosity
        
        # Step 2: Install
        Write-InstallationMessage "Step 2: Installing VideoFunctions module..." 'Info' $Verbosity
        $installScript = Join-Path $videoFunctionsDir 'Install-VideoFunctions.ps1'
        
        if (-not (Test-Path $installScript)) {
            throw "Install script not found at: $installScript"
        }
        
        Write-InstallationMessage "Executing install script with parameters: $($installParams | ConvertTo-Json -Compress)" 'Info' $Verbosity
        
        # Execute install script with parameters
        $installResult = & $installScript @installParams
        $installExitCode = $LASTEXITCODE
        
        if ($installExitCode -ne 0) {
            throw "Install failed with exit code: $installExitCode"
        }
        
        Write-InstallationMessage "Install completed successfully." 'Success' $Verbosity
    }
    
    # Import module if requested
    if ($ImportModule) {
        Write-InstallationMessage "Importing VideoFunctions module..." 'Info' $Verbosity
        try {
            Import-Module VideoFunctions -Force -ErrorAction Stop
            $importedFunctions = Get-Command -Module VideoFunctions -ErrorAction SilentlyContinue
            
            if ($importedFunctions) {
                Write-InstallationMessage "Module imported successfully. Found $($importedFunctions.Count) functions." 'Success' $Verbosity
                
                # Show available functions if verbosity allows
                if ($Verbosity -in @('Info', 'Success', 'All')) {
                    Write-InstallationMessage "Available functions:" 'Info' $Verbosity
                    foreach ($function in $importedFunctions) {
                        Write-InstallationMessage "  - $($function.Name)" 'Info' $Verbosity
                    }
                }
            } else {
                Write-InstallationMessage "Module imported but no functions found." 'Warning' $Verbosity
            }
        } catch {
            Write-InstallationMessage "Failed to import module: $($_.Exception.Message)" 'Error' $Verbosity
            throw
        }
    }
    
    # Restore original directory
    Write-InstallationMessage "Restoring original directory: $originalDirectory" 'Info' $Verbosity
    Set-Location $originalDirectory
    
    Write-InstallationMessage "Reinstallation completed successfully!" 'Success' $Verbosity
    Write-InstallationMessage "VideoFunctions module has been completely reinstalled." 'Info' $Verbosity
    
    if ($ImportModule) {
        Write-InstallationMessage "Module is now available for use. Example: Get-Command -Module VideoFunctions" 'Info' $Verbosity
    } else {
        Write-InstallationMessage "To use the module, run: Import-Module VideoFunctions" 'Info' $Verbosity
    }
    
} catch {
    Write-InstallationMessage "Reinstallation failed: $($_.Exception.Message)" 'Error' $Verbosity
    
    # Always try to restore the original directory, even on failure
    try {
        if ($originalDirectory -and (Test-Path $originalDirectory)) {
            Write-InstallationMessage "Restoring original directory after error: $originalDirectory" 'Warning' $Verbosity
            Set-Location $originalDirectory
        }
    } catch {
        Write-InstallationMessage "Failed to restore original directory: $($_.Exception.Message)" 'Error' $Verbosity
    }
    
    exit 1
} 