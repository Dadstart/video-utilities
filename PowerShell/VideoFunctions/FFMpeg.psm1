#
# Contains internal functions for ffmpeg and it's tools (ffplay, ffprobe, etc.)
function Get-FfmpegVersion {
    <#
    .SYNOPSIS
    Retrieves the version of ffmpeg installed on the system.

    .DESCRIPTION
    This function checks if ffmpeg is available in the system's PATH and returns its version.
    If ffmpeg is not found, it throws an error.

    .EXAMPLE
    Get-FfmpegVersion

    Returns the version of ffmpeg installed on the system.
    #>
    
    try {
        $ffmpegVersion = & ffmpeg -version | Select-Object -First 1
        return $ffmpegVersion
    } catch {
        throw "ffmpeg is not installed or not found in the system PATH."
    }
}

