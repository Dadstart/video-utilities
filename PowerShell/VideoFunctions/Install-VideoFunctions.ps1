#!/usr/bin/env pwsh

# Define enums for parameter validation
enum InstallScope {
    CurrentUser
    AllUsers
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

# Global verbosity setting
$script:VerbosityLevel = $Verbosity

function Write-InstallMessage {
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

function Get-ModuleInstallPath {
    param(
        [string]$Scope
    )
    
    if ($Scope -eq 'AllUsers') {
        if ($PSVersionTable.PSEdition -eq 'Core') {
            return "$env:ProgramFiles\PowerShell\Modules"
        } else {
            return "$env:ProgramFiles\WindowsPowerShell\Modules"
        }
    } else {
        if ($PSVersionTable.PSEdition -eq 'Core') {
            return "$env:USERPROFILE\Documents\PowerShell\Modules"
        } else {
            return "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
        }
    }
}

function Test-ModuleStructure {
    <#
    .SYNOPSIS
        Tests if the current directory contains a valid VideoFunctions module structure.
    #>
    $requiredFiles = @(
        'VideoFunctions.psd1',
        'VideoFunctions.psm1'
    )
    
    $requiredDirectories = @(
        'Public',
        'Private'
    )
    
    # Check for required files
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            Write-InstallMessage "Required file '$file' not found in current directory." 'Error'
            return $false
        }
    }
    
    # Check for required directories
    foreach ($dir in $requiredDirectories) {
        if (-not (Test-Path $dir)) {
            Write-InstallMessage "Required directory '$dir' not found in current directory." 'Error'
            return $false
        }
    }
    
    # Check for at least one function file in Public directory
    $publicFunctions = Get-ChildItem -Path 'Public' -Filter '*.ps1' -ErrorAction SilentlyContinue
    if ($publicFunctions.Count -eq 0) {
        Write-InstallMessage "No function files found in Public directory." 'Error'
        return $false
    }
    
    return $true
}

function Get-ModuleVersion {
    <#
    .SYNOPSIS
        Gets the version from the module manifest.
    #>
    try {
        $manifest = Import-PowerShellDataFile -Path 'VideoFunctions.psd1'
        return $manifest.ModuleVersion
    }
    catch {
        Write-InstallMessage "Failed to read module version from manifest: $($_.Exception.Message)" 'Warning'
        return 'Unknown'
    }
}

# Main installation logic
try {
    Write-InstallMessage "Starting VideoFunctions module installation..." 'Info'
    Write-InstallMessage "PowerShell Version: $($PSVersionTable.PSVersion)" 'Info'
    Write-InstallMessage "PowerShell Edition: $($PSVersionTable.PSEdition)" 'Info'
    Write-InstallMessage "Installation Scope: $Scope" 'Info'
    
    # Check if running from the correct directory
    if (-not (Test-ModuleStructure)) {
        throw "Current directory does not contain a valid VideoFunctions module structure. Please run this script from the VideoFunctions module directory."
    }
    
    # Check for administrative privileges if installing for all users
    if ($Scope -eq 'AllUsers' -and -not (Test-Administrator)) {
        throw "Administrative privileges are required to install for all users. Please run PowerShell as Administrator or use -Scope CurrentUser."
    }
    
    # Get installation path
    $installPath = Get-ModuleInstallPath -Scope $Scope
    $modulePath = Join-Path $installPath 'VideoFunctions'
    
    Write-InstallMessage "Installation path: $modulePath" 'Info'
    
    # Check if module already exists
    if (Test-Path $modulePath) {
        if ($Force) {
            Write-InstallMessage "Module already exists. Force flag specified, will overwrite existing installation." 'Warning'
        } else {
            throw "Module already exists at '$modulePath'. Use -Force to overwrite or -Scope CurrentUser to install for current user only."
        }
    }
    
    # Get current module version
    $moduleVersion = Get-ModuleVersion
    Write-InstallMessage "Installing VideoFunctions version $moduleVersion" 'Info'
    
    # Perform the installation
    if ($PSCmdlet.ShouldProcess($modulePath, "Install VideoFunctions module")) {
        # Create the module directory if it doesn't exist
        if (-not (Test-Path $installPath)) {
            Write-InstallMessage "Creating modules directory: $installPath"
            New-Item -Path $installPath -ItemType Directory -Force | Out-Null
        }
        
        # Copy the module files
        Write-InstallMessage "Copying module files to: $modulePath"
        Copy-Item -Path '.' -Destination $modulePath -Recurse -Force
        
        # Verify the installation
        if (Test-Path $modulePath) {
            Write-InstallMessage "Module files copied successfully." 'Success'
            
            # Test module import
            Write-InstallMessage "Testing module import..."
            try {
                Import-Module $modulePath -Force -ErrorAction Stop
                $importedFunctions = Get-Command -Module VideoFunctions
                Write-InstallMessage "Module imported successfully. Found $($importedFunctions.Count) functions." 'Success'
                
                # Show available functions
                Write-InstallMessage "Available functions:" 'Info'
                foreach ($function in $importedFunctions) {
                    Write-InstallMessage "  - $($function.Name)" 'Info'
                }
                
                # Remove the module to clean up
                Remove-Module VideoFunctions -Force -ErrorAction SilentlyContinue
                
            } catch {
                Write-InstallMessage "Module import test failed: $($_.Exception.Message)" 'Error'
                throw
            }
            
        } else {
            throw "Failed to copy module files to $modulePath"
        }
    }
    
    Write-InstallMessage "Installation completed successfully!" 'Success'
    Write-InstallMessage "To use the module, run: Import-Module VideoFunctions" 'Info'
    
    # Show usage examples
    Write-InstallMessage "Example usage:" 'Info'
    Write-InstallMessage "  Import-Module VideoFunctions" 'Info'
    Write-InstallMessage "  Get-Command -Module VideoFunctions" 'Info'
    Write-InstallMessage "  Get-Help Get-FFMpegVersion" 'Info'
    
} catch {
    Write-InstallMessage "Installation failed: $($_.Exception.Message)" 'Error'
    exit 1
} 