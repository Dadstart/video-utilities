enum StreamType {
    All
    Audio
    Video
    Subtitle
}

function Get-MpegStreams {
    <#
    .SYNOPSIS
    Retrieves an array of streams from a media file.

    .PARAMETER Name
    Media file

    .PARAMETER Type
    Type of stream to retrieve (e.g., 'Audio', 'Video', 'Subtitle'). Default is 'All'.

    .PARAMETER Language
    Language code to filter streams (e.g., 'eng' for English).

    .OUTPUTS
    [System.Object[]]
    Returns an array of streams filtered by type and language.

    .DESCRIPTION
    This function takes a media input file and scans ans returns all streams
    within the file. If a type is provided, it filters the streams based on the
    specified type. If a language code is provided, it filters the streams
    based on the specified language.

    .EXAMPLE
    Get-MpegStreams 'example.mp4' -Type Audio -Language 'eng'
    Retrieves all audio streams from 'example.mp4' that are in English.
    
    .EXAMPLE
    Get-MpegStreams 'example.mp4' -Type Video
    Retrieves all video streams from 'example.mp4'.

    .EXAMPLE
    Get-MpegStreams 'example.mp4' -Type Subtitle -Language 'eng'
    Retrieves all subtitle streams from 'example.mp4' that are in English.

    .EXAMPLE
    Get-MpegStreams 'example.mp4'
    Retrieves all streams from 'example.mp4' without filtering by type or language.
    #>
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$name,
        [Parameter(Mandatory = $false, Position = 1)]
        [StreamType]$type = [StreamType]::All,
        [Parameter(Mandatory = $false)]
        [string]$language = $null
    )

    $streams = Invoke-FFProbe '-show_streams', $name;
    $audioTracks = $streams.streams | Where-Object { 
        (($type -eq [StreamType]::All) -or ($_.codec_type -eq $type.ToString().ToLowerInvariant())) `
        -and `
        ((-not $language) -or ($_.tags.language -eq $language))
    }
    
    Write-Verbose "Found $($audioTracks.Count) audio tracks in $name with language code '$language'.";
    return $audioTracks;
}
