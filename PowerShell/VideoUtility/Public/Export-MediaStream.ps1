enum StreamType {
    Data
    Audio
    Video
    Subtitle
    None
}

function Export-MediaStream {
    <#
    .SYNOPSIS
        Extracts a stream from a media file using ffmpeg.

    .DESCRIPTION
        This function uses ffmpeg to extract a specific stream from a media file
        and outputs it as a raw stream file. The stream can be filtered by type
        (Audio, Video, Subtitle, Data, None) and selected by index.

    .PARAMETER InputPath
        Path to the input media file.

    .PARAMETER OutputPath
        Path where the raw stream file will be saved.

    .PARAMETER Type
        Type of stream to filter by. Must be one of: Audio, Video, Subtitle, Data, or None.

    .PARAMETER Index
        Zero-based index of the stream to extract. When Type is specified (Audio, Video, etc.),
        this is the index within that stream type. When Type is None, this is the absolute
        stream index regardless of type.

    .PARAMETER Force
        Overwrites the output file if it already exists.

    .PARAMETER WhatIf
        Shows what would happen if the command runs without actually executing it.

    .PARAMETER Confirm
        Prompts for confirmation before executing the command.

    .EXAMPLE
        Export-MediaStream -InputPath 'video.mp4' -OutputPath 'audio.raw' -Type Audio -Index 0
        Extracts the first audio stream from 'video.mp4' and saves it as 'audio.raw'.

    .EXAMPLE
        Export-MediaStream -InputPath 'video.mp4' -OutputPath 'video_stream.h264' -Type Video -Index 0
        Extracts the first video stream from 'video.mp4' and saves it as 'video_stream.h264'.

    .EXAMPLE
        Export-MediaStream -InputPath 'video.mp4' -OutputPath 'subtitle.ass' -Type Subtitle -Index 0
        Extracts the first subtitle stream from 'video.mp4' and saves it as 'subtitle.ass'.

    .EXAMPLE
        Export-MediaStream -InputPath 'video.mp4' -OutputPath 'stream_2.raw' -Type Data -Index 2 -Force
        Extracts the third data stream from 'video.mp4' and saves it as 'stream_2.raw', overwriting if it exists.

    .EXAMPLE
        Get-ChildItem -Filter "*.mp4" | Export-MediaStream -OutputPath "audio.aac" -Type Audio -Index 0
        Extracts the first audio stream from all MP4 files in the current directory and saves them as "audio.aac".

    .EXAMPLE
        Export-MediaStream -InputPath 'video.mp4' -OutputPath 'stream_3.raw' -Type None -Index 3
        Extracts the fourth stream (absolute index 3) from 'video.mp4' regardless of its type and saves it as 'stream_3.raw'.

    .OUTPUTS
        None. Creates a file at the specified OutputPath.

    .NOTES
        This function requires ffmpeg to be installed and available in the system PATH.
        The output file will contain the media stream data with container formatting.
        Valid stream types are defined in the StreamType enum: Audio, Video, Subtitle, Data, and None.
        When Type is None, the Index parameter refers to the absolute stream index (0-based) regardless of stream type.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$InputPath,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,

        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNull()]
        [StreamType]$Type,

        [Parameter(Mandatory, Position = 3)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Index,

        [Parameter()]
        [switch]$Force
    )

    process {
        Write-Verbose "Extract $Type stream at index $Index from '$InputPath' to '$OutputPath'"

        # Resolve and validate input path
        $InputPath = Resolve-Path $InputPath

        # Resolve output path relative to current working directory
        if ([System.IO.Path]::IsPathRooted($OutputPath)) {
            # Absolute path - use as is
            $OutputPath = [System.IO.Path]::GetFullPath($OutputPath)
        }
        else {
            # Relative path - resolve relative to current working directory
            $OutputPath = Join-Path (Get-Location) $OutputPath
            $OutputPath = [System.IO.Path]::GetFullPath($OutputPath)
        }
        Write-Verbose "Output path resolved: $OutputPath"

        # Create output directory if it doesn't exist        
        $outputDir = Split-Path $OutputPath -Parent
        if ($outputDir -and -not (Test-Path $outputDir)) {
            Write-Verbose "Creating output directory: $outputDir"
            if ($PSCmdlet.ShouldProcess($outputDir, 'Create directory')) {
                New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
            }
        }

        # Check if output file exists and handle Force parameter
        if (Test-Path $OutputPath) {
            if (-not $Force) {
                Write-Error "Output file already exists: $OutputPath. Use -Force to overwrite."
                return
            }
            else {
                Write-Verbose "Overwriting existing file: $OutputPath"
            }
        }


        # Build ffmpeg arguments
        # Should result in call to ffmpeg with argments: -i input.mkv -y -map 0:s:0 -c copy output.sup

        if ($Type -eq 'None') {
            $mapValue = "0:$Index"
        }
        else {
            # Stream type mapping
            $streamFilter = switch ($Type) {
                'Audio' { 'a' }
                'Video' { 'v' }
                'Subtitle' { 's' }
                'Data' { 'd' }
                default { Write-Error "Unsupported stream type: $Type" -ErrorAction Stop }
            }
            $mapValue = "0:$($streamFilter):$Index"
        }

        $quotedInputPath = '"' + $InputPath + '"'
        $quotedOutputPath = '"' + $OutputPath + '"'
        $ffmpegArgs = @(
            '-i', $quotedInputPath,
            '-y', # Overwrite output files
            '-map', $mapValue,
            '-c', 'copy',
            $quotedOutputPath
        )

        Write-Verbose "FFmpeg command: ffmpeg $($ffmpegArgs -join ' ')"

        $operation = "Extract $Type stream at index $Index from '$InputPath' to '$OutputPath'"

        if ($WhatIfPreference) {
            Write-Output "What if: $operation"
            Write-Output "Command: ffmpeg $($ffmpegArgs -join ' ')"
            return
        }

        $progressActivity = "Exporting $Type Stream $Index from $InputPath"
        if ($PSCmdlet.ShouldProcess($OutputPath, $operation)) {
            try {
                Write-Progress -Activity $progressActivity -Status "Processing $InputPath" -PercentComplete 0

                Write-Verbose "Executing: ffmpeg $($ffmpegArgs -join ' ')"

                Invoke-FFMpeg $ffmpegArgs

                Write-Progress -Activity $progressActivity -Status 'Complete' -PercentComplete 100
                Write-Verbose "Successfully exported stream to: $OutputPath"
            }
            catch {
                Write-Progress -Activity $progressActivity -Completed
                Write-Error "Failed to extract stream: $($_.Exception.Message)" -ErrorAction Stop
            }
        }
    }
}
