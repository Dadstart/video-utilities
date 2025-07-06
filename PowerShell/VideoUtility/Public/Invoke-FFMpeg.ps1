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

    .RETURNVALUE
        [PSCustomObject]@{
            Output   = [string] (Standard Output)
            Error    = [string] (Standard Error)
            ExitCode = [int] (Exit Code)
        }

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

    begin {
        # Pass through verbose/debug preferences to called functions
        $PSDefaultParameterValues['Invoke-Process:Verbose'] = $VerbosePreference
        $PSDefaultParameterValues['Invoke-Process:Debug'] = $DebugPreference
   }
    process {        
        # Check if ffmpeg is installed
        Test-FFMpegInstalled -Throw | Out-Null

        $finalArguments = @('-v', 'error', '-hide_banner') + $Arguments
        Write-Verbose "Invoke-FFMpeg: Arguments: $($finalArguments -join ' ')"
        $processResult = Invoke-Process ffmpeg $finalArguments

        Write-Debug "Invoke-FFMpeg: Process exit code: $($processResult.ExitCode)"
        Write-Debug "Invoke-FFMpeg: Output length: $($processResult.Output.Length)"
        Write-Debug "Invoke-FFMpeg: Error length: $($processResult.Error.Length)"
        if ($processResult.ExitCode -ne 0) {
            Write-Error "Invoke-FFMpeg: Failed to execute ffmpeg. Exit code: $($processResult.ExitCode)"
        }

        return $processResult
    }
}