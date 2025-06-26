function Invoke-FFProbe {
    <#
    .SYNOPSIS
        Retrieves an object converted from the JSON output from ffprobe.

    .DESCRIPTION
        This function runs ffprobe on the specified media file and returns the object
        parsed from the JSON format.

    .PARAMETER Arguments
        Arguments to pass to ffprobe.

    .EXAMPLE
        Invoke-FFProbe '-show_program_version'

        Returns an object like:
        @{
            program_version = @{
                version = '7.1.1-full_build-www.gyan.dev'
                copyright = 'Copyright (c) 2007-2025 the FFmpeg developers'
                ...
            }
        }

    .OUTPUTS
        [System.Management.Automation.PSCustomObject]
        Returns a custom object with the parsed results from the JSON output from ffprobe.

    .NOTES
        This function requires ffmpeg to be installed and available in the system PATH.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]$Arguments
    )

    # Check if ffmpeg is installed
    Test-FFMpegInstalled -Throw | Out-Null

    $finalArguments = @('-v', 'error', '-of', 'json') + $Arguments
    Write-Verbose "Invoke-FFProbe: Arguments: $($finalArguments -join ' ')"
    $json = Invoke-Process ffprobe $finalArguments
    $result = $json | ConvertFrom-Json

    return $result
}