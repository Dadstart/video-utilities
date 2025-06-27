#Requires -Version 7.0

<#
.SYNOPSIS
    VideoUtility PowerShell Module

.DESCRIPTION
    A PowerShell module for video processing and manipulation utilities.
    This module provides functions for working with video files, media analysis, and processing.

.NOTES
    Version: 0.2.0
    Author: Andrew Bishop
    Copyright: Copyright © Andrew Bishop
    PowerShell Version: 7.0+
#>

# Get the directory where this script is located
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load all private functions first
$privatePath = Join-Path $scriptPath "Private"
if (Test-Path $privatePath) {
    Get-ChildItem -Path $privatePath -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }
}

# Load all public functions
$publicPath = Join-Path $scriptPath "Public"
if (Test-Path $publicPath) {
    Get-ChildItem -Path $publicPath -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }
}

# Export public functions
Export-ModuleMember -Function @(
    'Export-MediaStream',
    'Get-FFMpegVersion',
    'Get-MediaStream',
    'Get-MediaStreams',
    'Get-MkvTrack',
    'Get-MkvTrackAll',
    'Get-MkvTracks',
    'Add-PlexFolder',
    'Invoke-PlexFileOperation',
    'Move-PlexFile',
    'Remove-PlexEmptyFolder'
)