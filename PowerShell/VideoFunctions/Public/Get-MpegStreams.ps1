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

    .DESCRIPTION
        This function takes a media input file and scans and returns all streams
        within the file. If a type is provided, it filters the streams based on the
        specified type. If a language code is provided, it filters the streams
        based on the specified language.

    .PARAMETER Name
        Media file path.

    .PARAMETER Type
        Type of stream to retrieve (e.g., 'Audio', 'Video', 'Subtitle'). Default is 'All'.

    .PARAMETER Language
        Language code to filter streams (e.g., 'eng' for English).

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

    .OUTPUTS
        [System.Object[]]
        Returns an array of streams filtered by type and language.

    .NOTES
        This function requires ffmpeg to be installed and available in the system PATH.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name,
        [Parameter(Mandatory = $false, Position = 1)]
        [StreamType]$Type = [StreamType]::All,
        [Parameter(Mandatory = $false)]
        [string]$Language = $null
    )

    $allStreams = Invoke-FFProbe '-show_streams', $Name
    $matchingStreams = $allStreams.streams | Where-Object { 
        (($Type -eq [StreamType]::All) -or ($_.codec_type -eq $Type.ToString().ToLowerInvariant())) `
        -and `
        ((-not $Language) -or ($_.tags.language -eq $Language))
    }
    
    Write-Verbose "Found $($matchingStreams.Count) streams in $Name with language code '$Language'."
    return $matchingStreams
} 