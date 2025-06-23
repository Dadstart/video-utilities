#Requires -Version 5.1

<#
.SYNOPSIS
    VideoFunctions PowerShell Module

.DESCRIPTION
    A PowerShell module for video file processing and Plex folder management.
    This module provides functions for working with FFmpeg, MKV files, and Plex media organization.

.NOTES
    Version: 1.0.1
    Author: Andrew Bishop
    Copyright: Copyright © Andrew Bishop 2025
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
    # FFMpeg functions
    'Get-FFMpegVersion',

    # Media functions
    'Get-MediaStream',
    'Get-MediaStreams',
    'Export-MediaStreamContent',

    # MKV functions
    'Get-MkvTrack',
    'Get-MkvTracks',
    'Get-MkvTrackAll',

    # MPEG functions
    'Get-MpegStreams',

    # Plex functions
    'Add-PlexFolders',
    'Move-PlexFiles',
    'Remove-PlexEmptyFolders',
    'Invoke-PlexFileOperations'
) 