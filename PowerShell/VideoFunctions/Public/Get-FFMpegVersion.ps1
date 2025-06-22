function Get-FFMpegVersion {
    <#
    .SYNOPSIS
        Retrieves the version of ffmpeg installed on the system.

    .DESCRIPTION
        This function checks if ffmpeg is available in the system's PATH and returns its version.
        If ffmpeg is not found, it throws an error.

    .EXAMPLE
        Get-FFMpegVersion

        Returns the version of ffmpeg installed on the system, ex. '7.1.1-full_build-www.gyan.dev'

    .OUTPUTS
        [string]
        Returns the version string of the installed ffmpeg.

    .NOTES
        This function requires ffmpeg to be installed and available in the system PATH.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    Test-FFMpegInstalled -Throw $true | Out-Null
    
    $result = Invoke-FFProbe '-show_program_version'

    return $result.program_version.version
} 