function Add-MediaStream {
    <#
    .SYNOPSIS
        Adds additional media streams to an existing video file.

    .DESCRIPTION
        This function uses FFmpeg to add additional audio, video, or subtitle streams to an existing video file.
        Each stream object must contain File, Language, Title, and Type properties.
        The function preserves the original video stream and adds the specified streams with proper metadata.

    .PARAMETER Streams
        An array of stream objects, each containing:
        - File: Path to the media file containing the stream
        - Language: Language code (e.g., 'eng', 'spa', 'fra')
        - Title: Display title for the stream
        - Type: Stream type ('Audio', 'Video', 'Subtitle')

    .PARAMETER InputPath
        Path to the source video file that will receive the additional streams.

    .PARAMETER OutputPath
        Path where the output file with added streams will be saved.

    .EXAMPLE
        $streams = @(
            [PSCustomObject]@{
                File = 'audio-eng.m4a'
                Language = 'eng'
                Title = 'English Stereo'
                Type = 'Audio'
            },
            [PSCustomObject]@{
                File = 'audio-spa.m4a'
                Language = 'spa'
                Title = 'Spanish Stereo'
                Type = 'Audio'
            }
        )
        
        Add-MediaStream -Streams $streams -InputPath 'movie.mp4' -OutputPath 'movie-multiaudio.mp4'
        
        # Adds English and Spanish audio tracks to movie.mp4

    .EXAMPLE
        $subtitleStream = [PSCustomObject]@{
            File = 'subtitles-eng.srt'
            Language = 'eng'
            Title = 'English Subtitles'
            Type = 'Subtitle'
        }
        
        Add-MediaStream -Streams $subtitleStream -InputPath 'movie.mp4' -OutputPath 'movie-with-subs.mp4'
        
        # Adds English subtitle track to movie.mp4

    .EXAMPLE
        $streams = @(
            [PSCustomObject]@{
                File = 'commentary.m4a'
                Language = 'eng'
                Title = 'Director Commentary'
                Type = 'Audio'
            }
        )
        
        'movie.mp4' | Add-MediaStream -Streams $streams -OutputPath 'movie-commentary.mp4'
        
        # Uses pipeline to add commentary track to movie.mp4

    .OUTPUTS
        None. Creates a new video file with the specified streams added.

    .NOTES
        - Requires FFmpeg to be installed and available in the system PATH
        - The original video stream is preserved and copied without re-encoding
        - Audio streams are copied without re-encoding to preserve quality
        - The -shortest flag ensures the output duration matches the shortest input stream
        - Stream metadata (language and title) is properly set for media players
        - Input files must exist and be valid media files
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({
                $_.File -and $_.Language -and $_.Title -and $_.Type
            })]
        [PSCustomObject[]]$Streams,
        [Parameter(Mandatory)]
        [string]$InputPath,
        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    # Build input arguments
    $inputs = [System.Collections.ArrayList]::new()
    $maps = [System.Collections.ArrayList]::new()
    $metadata = [System.Collections.ArrayList]::new()
    
    $inputs.Add('-i')
    $inputs.Add("`"$InputPath`"")
    $maps.Add('-map')
    $maps.Add('0:v')

    for ($i = 0; $i -lt $Streams.Count; $i++) {
        $stream = $Streams[$i]

        $inputs.Add('-i')
        $inputs.Add("`"$($stream.File)`"")

        $streamType = $stream.Type.ToString().ToLowerInvariant()
        $maps.Add('-map')
        $maps.Add("$i`:$streamType")

        $metadata.Add("-metadata:s:$streamType`:$i language=$($stream.Language)")
        $metadata.Add("-metadata:s:$streamType`:$i title=`"$($stream.Title)`"")
    }

    # Assemble the final ffmpeg command
    $args = [System.Collections.ArrayList]::new()
    $args.AddRange($inputs)
    $args.AddRange($maps)
    $args.Add('-c:v')
    $args.Add('copy')
    $args.Add('-c:a')
    $args.Add('copy')
    $args.Add('-shortest')
    $args.AddRange($metadata)
    $args.Add("`"$OutputPath`"")

    Write-Host "Adding $($Streams.Count) streams to $OutputPath"
    Write-Verbose "FFmpeg command: ffmpeg $($args -join ' ')"
    Invoke-FFMpeg $args.ToArray()
}
