#!/usr/bin/env pwsh

# Define enums for parameter validation
enum ReinstallScope {
    CurrentUser
    AllUsers
    All
}

enum VerbosityLevel {
    Silent
    Error
    Warning
    Info
    Success
    All
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

# Global verbosity setting
$script:VerbosityLevel = $Verbosity

function Write-ReinstallMessage {
    param(
        [string]$Message,
        [string]$Type = 'Info'
    )
    
    # Check if message should be displayed based on verbosity level
    $shouldDisplay = switch ($script:VerbosityLevel) {
        'Silent'   { $Type -eq 'Error' }
        'Error'    { $Type -in @('Error') }
        'Warning'  { $Type -in @('Error', 'Warning') }
        'Info'     { $Type -in @('Error', 'Warning', 'Info') }
        'Success'  { $Type -in @('Error', 'Warning', 'Info', 'Success') }
        'All'      { $true }
        default    { $true }
    }
    
    if (-not $shouldDisplay) {
        return
    }
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    switch ($Type) {
        'Info'    { Write-Host "[$timestamp] INFO: $Message" -ForegroundColor Cyan }
        'Success' { Write-Host "[$timestamp] SUCCESS: $Message" -ForegroundColor Green }
        'Warning' { Write-Host "[$timestamp] WARNING: $Message" -ForegroundColor Yellow }
        'Error'   { Write-Host "[$timestamp] ERROR: $Message" -ForegroundColor Red }
    }
}

function Test-Administrator {
    <#
    .SYNOPSIS
        Tests if the current session is running with administrative privileges.
    #>
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Find-VideoFunctionsDirectory {
    <#
    .SYNOPSIS
        Finds the VideoFunctions module directory by searching common locations.
    #>
    $searchPaths = @(
        $PSScriptRoot,
        (Split-Path $PSScriptRoot -Parent),
        (Get-Location).Path,
        "$env:USERPROFILE\Documents\PowerShell\Modules\VideoFunctions",
        "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\VideoFunctions",
        "$env:ProgramFiles\PowerShell\Modules\VideoFunctions",
        "$env:ProgramFiles\WindowsPowerShell\Modules\VideoFunctions"
    )
    
    foreach ($path in $searchPaths) {
        if (Test-Path (Join-Path $path 'VideoFunctions.psd1')) {
            return $path
        }
    }
    
    return $null
}

function Build-UninstallParameters {
    <#
    .SYNOPSIS
        Builds the parameter hashtable for the uninstall script.
    #>
    $params = @{}
    
    if ($Scope -ne 'All') {
        $params['Scope'] = $Scope
    }
    
    if ($Force) {
        $params['Force'] = $true
    }
    
    if ($Verbosity -ne 'All') {
        $params['Verbosity'] = $Verbosity
    }
    
    if ($WhatIfPreference) {
        $params['WhatIf'] = $true
    }
    
    if ($ConfirmPreference -eq 'None') {
        $params['Confirm'] = $false
    }
    
    return $params
}

function Build-InstallParameters {
    <#
    .SYNOPSIS
        Builds the parameter hashtable for the install script.
    #>
    $params = @{}
    
    # For install, use CurrentUser if Scope is All, otherwise use the specified scope
    $installScope = if ($Scope -eq 'All') { 'CurrentUser' } else { $Scope }
    $params['Scope'] = $installScope
    
    if ($Force) {
        $params['Force'] = $true
    }
    
    if ($Verbosity -ne 'All') {
        $params['Verbosity'] = $Verbosity
    }
    
    if ($WhatIfPreference) {
        $params['WhatIf'] = $true
    }
    
    if ($ConfirmPreference -eq 'None') {
        $params['Confirm'] = $false
    }
    
    return $params
}

# Main reinstallation logic
try {
    Write-ReinstallMessage "Starting VideoFunctions module reinstallation..." 'Info'
    Write-ReinstallMessage "PowerShell Version: $($PSVersionTable.PSVersion)" 'Info'
    Write-ReinstallMessage "PowerShell Edition: $($PSVersionTable.PSEdition)" 'Info'
    Write-ReinstallMessage "Reinstallation Scope: $Scope" 'Info'
    
    # Save current directory
    $originalDirectory = Get-Location
    Write-ReinstallMessage "Original directory: $originalDirectory" 'Info'
    
    # Check for administrative privileges if needed
    if ($Scope -eq 'AllUsers' -and -not (Test-Administrator)) {
        throw "Administrative privileges are required to reinstall for all users. Please run PowerShell as Administrator or use -Scope CurrentUser."
    }
    
    # Find VideoFunctions directory
    $videoFunctionsDir = Find-VideoFunctionsDirectory
    if (-not $videoFunctionsDir) {
        throw "VideoFunctions module directory not found. Please ensure this script is run from or near the VideoFunctions module directory."
    }
    
    Write-ReinstallMessage "Found VideoFunctions directory: $videoFunctionsDir" 'Info'
    
    # Navigate to VideoFunctions directory
    Write-ReinstallMessage "Navigating to VideoFunctions directory..." 'Info'
    Set-Location $videoFunctionsDir
    
    # Build parameter hashtables
    $uninstallParams = Build-UninstallParameters
    $installParams = Build-InstallParameters
    
    Write-ReinstallMessage "Uninstall parameters: $($uninstallParams | ConvertTo-Json -Compress)" 'Info'
    Write-ReinstallMessage "Install parameters: $($installParams | ConvertTo-Json -Compress)" 'Info'
    
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
        Write-ReinstallMessage "Step 1: Uninstalling VideoFunctions module..." 'Info'
        $uninstallScript = Join-Path $videoFunctionsDir 'Uninstall-VideoFunctions.ps1'
        
        if (-not (Test-Path $uninstallScript)) {
            throw "Uninstall script not found at: $uninstallScript"
        }
        
        Write-ReinstallMessage "Executing uninstall script with parameters: $($uninstallParams | ConvertTo-Json -Compress)" 'Info'
        
        # Execute uninstall script with parameters
        $uninstallResult = & $uninstallScript @uninstallParams
        $uninstallExitCode = $LASTEXITCODE
        
        if ($uninstallExitCode -ne 0) {
            throw "Uninstall failed with exit code: $uninstallExitCode"
        }
        
        Write-ReinstallMessage "Uninstall completed successfully." 'Success'
        
        # Step 2: Install
        Write-ReinstallMessage "Step 2: Installing VideoFunctions module..." 'Info'
        $installScript = Join-Path $videoFunctionsDir 'Install-VideoFunctions.ps1'
        
        if (-not (Test-Path $installScript)) {
            throw "Install script not found at: $installScript"
        }
        
        Write-ReinstallMessage "Executing install script with parameters: $($installParams | ConvertTo-Json -Compress)" 'Info'
        
        # Execute install script with parameters
        $installResult = & $installScript @installParams
        $installExitCode = $LASTEXITCODE
        
        if ($installExitCode -ne 0) {
            throw "Install failed with exit code: $installExitCode"
        }
        
        Write-ReinstallMessage "Install completed successfully." 'Success'
    }
    
    # Import module if requested
    if ($ImportModule) {
        Write-ReinstallMessage "Importing VideoFunctions module..." 'Info'
        try {
            Import-Module VideoFunctions -Force -ErrorAction Stop
            $importedFunctions = Get-Command -Module VideoFunctions -ErrorAction SilentlyContinue
            
            if ($importedFunctions) {
                Write-ReinstallMessage "Module imported successfully. Found $($importedFunctions.Count) functions." 'Success'
                
                # Show available functions if verbosity allows
                if ($script:VerbosityLevel -in @('Info', 'Success', 'All')) {
                    Write-ReinstallMessage "Available functions:" 'Info'
                    foreach ($function in $importedFunctions) {
                        Write-ReinstallMessage "  - $($function.Name)" 'Info'
                    }
                }
            } else {
                Write-ReinstallMessage "Module imported but no functions found." 'Warning'
            }
        } catch {
            Write-ReinstallMessage "Failed to import module: $($_.Exception.Message)" 'Error'
            throw
        }
    }
    
    # Restore original directory
    Write-ReinstallMessage "Restoring original directory: $originalDirectory" 'Info'
    Set-Location $originalDirectory
    
    Write-ReinstallMessage "Reinstallation completed successfully!" 'Success'
    Write-ReinstallMessage "VideoFunctions module has been completely reinstalled." 'Info'
    
    if ($ImportModule) {
        Write-ReinstallMessage "Module is now available for use. Example: Get-Command -Module VideoFunctions" 'Info'
    } else {
        Write-ReinstallMessage "To use the module, run: Import-Module VideoFunctions" 'Info'
    }
    
} catch {
    Write-ReinstallMessage "Reinstallation failed: $($_.Exception.Message)" 'Error'
    
    # Always try to restore the original directory, even on failure
    try {
        if ($originalDirectory -and (Test-Path $originalDirectory)) {
            Write-ReinstallMessage "Restoring original directory after error: $originalDirectory" 'Warning'
            Set-Location $originalDirectory
        }
    } catch {
        Write-ReinstallMessage "Failed to restore original directory: $($_.Exception.Message)" 'Error'
    }
    
    exit 1
} 