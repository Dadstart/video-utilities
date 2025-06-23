enum StreamType {
    All
    Audio
    Video
    Subtitle
}

function Get-MediaStream {
    <#
    .SYNOPSIS
        Retrieves a single stream from a media file by index with optional type filtering.

    .DESCRIPTION
        This function takes a media input file and returns a specific stream
        based on the provided index. The index corresponds to the stream's
        position in the file (0-based). Optionally filters by stream type
        before selecting by index.

    .PARAMETER Name
        Media file path.

    .PARAMETER Index
        Zero-based index of the stream to retrieve (after type filtering).

    .PARAMETER Type
        Type of stream to filter by (e.g., 'Audio', 'Video', 'Subtitle'). Default is 'All'.

    .EXAMPLE
        Get-MediaStream 'example.mp4' -Index 0
        Retrieves the first stream (index 0) from 'example.mp4'.
    
    .EXAMPLE
        Get-MediaStream 'example.mp4' -Index 2 -Type Video
        Retrieves the third video stream (index 2) from 'example.mp4'.

    .EXAMPLE
        Get-MediaStream 'example.mp4' 1 -Type Audio
        Retrieves the second audio stream (index 1) from 'example.mp4' using positional parameter.

    .EXAMPLE
        Get-MediaStream 'example.mp4' -Index 0 -Type Subtitle
        Retrieves the first subtitle stream (index 0) from 'example.mp4'.

    .OUTPUTS
        [object]
        Returns a single stream object at the specified index (after type filtering).

    .NOTES
        This function requires ffmpeg to be installed and available in the system PATH.
        If the specified index is out of range for the filtered streams, the function will return $null.
        The index applies to streams of the specified type, not all streams in the file.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name,
        [Parameter(Mandatory = $true, Position = 1)]
        [int]$Index,
        [Parameter(Mandatory = $false)]
        [StreamType]$Type = [StreamType]::All
    )

    if ($Type -eq [StreamType]::All) {
        $codecFilter = $null
    } else {
        $t = $Type.ToString().Substring(0, 1).ToLowerInvariant()
        $codecFilter = "$t`:"
    }

    $streams = Invoke-FFProbe "-select_streams $codecFilter$Index -show_streams", $Name
    $stream = $streams.streams[0]
    Write-Verbose "Retrieved $Type stream at index $Index from $Name (type: $($stream.codec_type))."
    return $stream
} 