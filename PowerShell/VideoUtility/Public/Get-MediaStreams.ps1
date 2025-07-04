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
        Scans a media file using ffprobe and returns filtered streams.
        Each stream object contains Index, CodecType, CodecName, Language, Disposition, and Tags properties.

    .PARAMETER Path
        Path to the media file.

    .PARAMETER Type
        Type of stream to retrieve ('Audio', 'Video', 'Subtitle', or 'All').
        Default is 'All'.

    .EXAMPLE
        Get-MediaStreams 'example.mp4' -Type Audio
        # Retrieves all audio streams from 'example.mp4'.

    .EXAMPLE
        Get-MediaStreams 'example.mp4' -Type Video
        # Retrieves all video streams from 'example.mp4'.

    .EXAMPLE
        Get-MediaStreams 'example.mp4' -Type Subtitle
        # Retrieves all subtitle streams from 'example.mp4'.

    .EXAMPLE
        Get-MediaStreams 'example.mp4'
        # Retrieves all streams from 'example.mp4'.

    .OUTPUTS
        [object[]] Array of stream objects with Index, CodecType, CodecName, Language, Disposition, and Tags properties.

    .NOTES
        Requires ffmpeg/ffprobe to be installed and available in the system PATH.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [string]$Path,
        [Parameter(Position = 1)]
        [StreamType]$Type = [StreamType]::All
    )
    begin {
        Write-Debug "Parameters: $($PSBoundParameters | ConvertTo-Json)"
        $streamTypeString = $Type.ToString().ToLowerInvariant()
    }

    process {
        # Resolve path to absolute path
        if ([System.IO.Path]::IsPathRooted($Path)) {
            $resolvedPath = $Path
        }
        else {
            $resolvedPath = Join-Path (Get-Location) $Path
        }

        # Validate the file path before proceeding
        if (-not (Test-Path -Path $resolvedPath -PathType Leaf)) {
            Write-Error "The file path '$resolvedPath' does not exist or is not a valid file." -ErrorAction Stop
        }

        Write-Verbose "Processing file: $resolvedPath"

        try {
            # Get all streams from the file using ffprobe
            Write-Verbose 'Running ffprobe to get stream information'
            $processResult = Invoke-FFProbe '-show_streams', "`"$resolvedPath`""
            if ($processResult.ExitCode) {
                Write-Error "Get-MediaStreams: Failed to get media streams. Exit code: $($processResult.ExitCode)"
                return @()
            }

            # Get streams from the result object
            $allStreams = $processResult.Json.streams

            # Return empty array if no streams found
            if (-not $allStreams) {
                Write-Verbose "No streams found in file '$resolvedPath'"
                return @()
            }

            Write-Verbose "Found $($allStreams.Count) total streams"

            # Filter streams based on type
            $filteredStreams = @()
            $typeIndex = 0

            foreach ($stream in $allStreams) {
                # Check if stream matches the requested type
                $matchesType = ($Type -eq [StreamType]::All) -or ($stream.codec_type -eq $streamTypeString)
            
                if ($matchesType) {
                    Write-Verbose "Processing stream $($stream.index) of type $($stream.codec_type)"                

                    # Create stream object with required properties
                    $streamObj = [PSCustomObject]@{
                        Index       = [int]$stream.index
                        CodecType   = [string]$stream.codec_type
                        CodecName   = [string]$stream.codec_name
                        TypeIndex   = [int]$typeIndex
                        Language    = [string]$stream.tags.language
                        Title       = [string]$stream.tags.title    
                        Disposition = $stream.disposition
                        Tags        = $stream.tags
                    }

                    $filteredStreams += $streamObj
                    $typeIndex++
                }
            }

            Write-Verbose "Returning $($filteredStreams.Count) filtered streams of type '$Type'"
            return $filteredStreams
        }
        catch {
            Write-Error "Failed to get media streams from '$resolvedPath': $($_.Exception.Message)" -ErrorAction Stop
            return @()
        }
    }
    end {
    }
}