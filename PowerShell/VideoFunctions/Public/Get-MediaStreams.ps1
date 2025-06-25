enum StreamType {
    All
    Audio
    Video
    Subtitle
}

function Get-MediaStreams {
    <#
    .SYNOPSIS
        Retrieves an array of streams from a media file.

    .DESCRIPTION
        Scans a media file and returns all streams (audio, video, subtitle, etc).
        Optionally filters by stream type and/or language code.

    .PARAMETER Path
        Path to the media file.

    .PARAMETER Type
        Type of stream to retrieve ('Audio', 'Video', 'Subtitle', or 'All').
        Default is 'All'.

    .PARAMETER Language
        Language code to filter streams (e.g., 'eng' for English).

    .EXAMPLE
        Get-MediaStreams 'example.mp4' -Type Audio -Language 'eng'
        # Retrieves all English audio streams from 'example.mp4'.

    .EXAMPLE
        Get-MediaStreams 'example.mp4' -Type Video
        # Retrieves all video streams from 'example.mp4'.

    .EXAMPLE
        Get-MediaStreams 'example.mp4' -Type Subtitle -Language 'eng'
        # Retrieves all English subtitle streams from 'example.mp4'.

    .EXAMPLE
        Get-MediaStreams 'example.mp4'
        # Retrieves all streams from 'example.mp4' with no filtering.

    .OUTPUTS
        [object[]] Array of stream objects, each with stream index,
        type, and language info.

    .NOTES
        Requires ffmpeg/ffprobe to be installed and available in the system PATH.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,
        [Parameter(Position = 1)]
        [StreamType]$Type = [StreamType]::All,
        [Parameter()]
        [string]$Language
    )

    # Validate the file path before proceeding
    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        Write-Error "The file path '$Path' does not exist or is not a valid file." -ErrorAction Stop
    }

    # Resolve path relative to current working directory
    if ([System.IO.Path]::IsPathRooted($Path)) {
        # Absolute path - use as is
        $Path = [System.IO.Path]::GetFullPath($Path)
    } else {
        # Relative path - resolve relative to current working directory
        $Path = Join-Path (Get-Location) $Path
        $Path = [System.IO.Path]::GetFullPath($Path)
    }
    Write-Verbose "Output path resolved: $Path"

    # Get all streams from the file using ffprobe
    $ffprobeResult = Invoke-FFProbe '-show_streams', $Path
    $streams = $ffprobeResult.streams

    # Return an empty array if no streams are found
    if (-not $streams) {
        Write-Verbose "No streams found in file '$Path'."
        return @()
    }

    # Prepare to collect filtered streams
    $filteredStreams = [System.Collections.ArrayList]::new()
    $streamTypeString = $Type.ToString().ToLowerInvariant()

    for ($i = 0; $i -lt $streams.Count; $i++) {
        $stream = $streams[$i]

        # Check if the stream matches the requested type and language
        $matchesType = ($Type -eq [StreamType]::All) -or ($stream.codec_type -eq $streamTypeString)
        $matchesLanguage = (-not $Language) -or ($stream.tags.language -eq $Language)

        if ($matchesType -and $matchesLanguage) {
            # Build a custom object for each matching stream
            $streamObj = [PSCustomObject]@{
                Index       = $stream.index
                CodecType   = $stream.codec_type
                TypeIndex   = if ($Type -ne [StreamType]::All) { $filteredStreams.Count } else { $null }
                CodecName   = $stream.codec_name
                Language    = $stream.tags.language
                Disposition = $stream.disposition
                Tags        = $stream.tags
                # Convert the stream to a JSON object and back to a PSObject to deep copy the object
                Stream      = $stream | ConvertTo-Json | ConvertFrom-Json
            }
            $filteredStreams.Add($streamObj) | Out-Null
        }
    }

    # Return the array of filtered stream objects
    return , $filteredStreams.ToArray()
}
