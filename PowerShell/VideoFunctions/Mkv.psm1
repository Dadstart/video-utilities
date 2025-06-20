<#
.SYNOPSIS
    Extracts an audio or subtitle track from an MKV.

.DESCRIPTION
    This function takes an MKV, track number and extracts it appending the specified extension.

.PARAMETER Name
    File name of the MKV file.

.PARAMETER Track
    Track number to extract.

.PARAMETER Extension
    File extension to append to the track output.

.EXAMPLE
    Get-MkvTrack 'Move.mkv' 2 en.sdh.sup

    Outputs track 2 to 'Movie.en.sdh.sup'

.INPUTS
    [string]
    [int]
    [string]
#>
function Get-MkvTrack {
    param (
        [Parameter(Mandatory)]
        [string]$name,
        [Parameter(Mandatory)]
        [int]$track,
        [Parameter(Mandatory)]
        [string]$extension
    )

    if ($name.EndsWith(".mkv")) { $name = $name.Substring(0, $name.Length - 4); }
    Write-Host "Extracting track $track from '$name.mkv'" -ForegroundColor Blue;

    $outputName = "$name.$extension";
    mkvextract "$name.mkv" tracks $track`:"$outputName";

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed (Exit code: $LASTEXITCODE)" -ForegroundColor Red;
    }
    else {
        Write-Host "Complete" -ForegroundColor Blue;
    }
}

<#
.SYNOPSIS
    Extracts multiple audio or subtitle tracks from an MKV.

.DESCRIPTION
    This function takes an MKV, a list of track numbers and extracts them appending the specified extension.

.PARAMETER Name
    File name of the MKV file.

.PARAMETER Track
    Array of track numbers to extract.

.PARAMETER Extension
    File extension to append to the track output.

.EXAMPLE
    Get-MkvTracks 'Move.mkv' (2,3) ac3

    Outputs track 2 to 'Movie.2.ac3'
    Outputs track 3 to 'Movie.3.ac3'

.INPUTS
    [string]
    [int[]]
    [string]
#>
function Get-MkvTracks {
    param (
        [Parameter(Mandatory)]
        [string]$name,
        [Parameter(Mandatory)]
        [int[]]$tracks,
        [Parameter(Mandatory)]
        [string]$extension
    )

    foreach ($track in $tracks) {
        $finalExtension = "$track.$extension";
        Get-MkvTrack $name $track $finalExtension;
    }
}

<#
.SYNOPSIS
    Extracts an audio or subtitle track from multiple files.

.DESCRIPTION
    This function takes list of MKV filse, a track number and extracts them appending the specified extension.

.PARAMETER Names
    Files name of the MKV file.

.PARAMETER Track
    Track number to extract.

.PARAMETER Extension
    File extension to append to the track outputs.

.EXAMPLE
    Get-MkvTrackAll ('Move.mkv','Film.mkv') 2 en.sdh.sup

    Outputs track 2 from 'Move.mkv' to 'Movie.en.sdh.sup'
    Outputs track 2 from 'Film.mkv' to 'Film.en.sdh.sup'

.INPUTS
    [string[]]
    [int]
    [string]
#>
function Get-MkvTrackAll {
    param (
        [Parameter(Mandatory)]
        [string[]]$names,
        [Parameter(Mandatory)]
        [int]$track,
        [Parameter(Mandatory)]
        [string]$extension
    )

    foreach ($name in $names) {
        Get-MkvTrack "$name" @($track) $extension -NoTrackExtension;
    }
}
