function Invoke-FFMpeg {
    [CmdletBinding()]
    <#
    .SYNOPSIS
        Executes ffmpeg with the specified arguments and returns the output.

    .DESCRIPTION
        This function runs ffmpeg with the specified arguments and returns the raw output
        from the command execution.

    .PARAMETER Arguments
        Arguments to pass to ffmpeg.

    .EXAMPLE
        Invoke-FFMpeg '-version'

        Returns the raw output from ffmpeg version command.

    .OUTPUTS
        [string]
        Returns the raw output from the ffmpeg command execution.

    .NOTES
        This function requires ffmpeg to be installed and available in the system PATH.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]$Arguments
    )

    # Check if ffmpeg is installed
    Test-FFMpegInstalled -Throw | Out-Null

    $finalArguments = @('-v', 'error', '-hide_banner') + $Arguments

    Write-Verbose "Invoke-FFMpeg: Arguments: $($finalArguments -join ' ')"
    $result = Invoke-Process ffmpeg $finalArguments

    return $result
}