#Requires -Version 7.0

<#
.SYNOPSIS
    VideoUtility PowerShell Module

.DESCRIPTION
    A PowerShell module for video processing and manipulation utilities.
    This module provides functions for working with video files, media analysis, and processing.

.NOTES
    Version: 0.2.0
    Author: Dadstart
    Copyright: Copyright © Dadstart
    PowerShell Version: 7.0+
#>

# Get the directory where this script is located
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load all private functions first
$privatePath = Join-Path $scriptPath 'Private'
if (Test-Path $privatePath) {
    Get-ChildItem -Path $privatePath -Filter '*.ps1' | ForEach-Object {
        . $_.FullName
    }
}

# Load classes first in the correct order (base class before derived class)
$publicPath = Join-Path $scriptPath 'Public'
if (Test-Path $publicPath) {
    # Load ProcessResult class first
    $processResultPath = Join-Path $publicPath 'ProcessResult.ps1'
    if (Test-Path $processResultPath) {
        . $processResultPath
    }
    
    # Load FFProbeResult class second
    $ffProbeResultPath = Join-Path $publicPath 'FFProbeResult.ps1'
    if (Test-Path $ffProbeResultPath) {
        . $ffProbeResultPath
    }
    
    # Load MediaStreamInfo class third
    $mediaStreamInfoPath = Join-Path $publicPath 'MediaStreamInfo.ps1'
    if (Test-Path $mediaStreamInfoPath) {
        . $mediaStreamInfoPath
    }
    
    # Load all other public functions (excluding the class files)
    Get-ChildItem -Path $publicPath -Filter '*.ps1' | Where-Object { 
        $_.Name -notin @('ProcessResult.ps1', 'FFProbeResult.ps1', 'MediaStreamInfo.ps1') 
    } | ForEach-Object {
        . $_.FullName
    }
}

# Export public functions
Export-ModuleMember -Function @(
    'Add-MediaStream',
    'Export-MediaStream',
    'Export-MediaStreams',
    'Get-FFMpegVersion',
    'Get-MediaStream',
    'Get-MediaStreams',
    'Get-MkvTrack',
    'Get-MkvTrackAll',
    'Get-MkvTracks',
    'Add-PlexFolder',
    'Invoke-FFMpeg',
    'Invoke-FFProbe',
    'Invoke-Process',
    'Invoke-PlexFileOperation',
    'Move-PlexFile',
    'Remove-PlexEmptyFolder'
)