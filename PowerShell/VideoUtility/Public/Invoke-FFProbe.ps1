function Invoke-FFProbe {
    <#
    .SYNOPSIS
        Retrieves an object converted from the JSON output from ffprobe.

    .DESCRIPTION
        This function runs ffprobe on the specified media file and returns the object
        parsed from the JSON format.

    .PARAMETER Arguments
        Arguments to pass to ffprobe.

    .RETURNVALUE
        [PSCustomObject]@{
            Json     = [PSCustomObject] (JSON Output)
            Output   = [string] (Standard Output)
            Error    = [string] (Standard Error)
            ExitCode = [int] (Exit Code)
        }

    .EXAMPLE
        Invoke-FFProbe '-show_program_version'

        Returns an object like:
        [PSCustomObject]@{
            Json     = [PSCustomObject]@{
                program_version = @{
                    version = '7.1.1-full_build-www.gyan.dev'
                    copyright = 'Copyright (c) 2007-2025 the FFmpeg developers'
                    ...
                }
            }
            Output   = [string] (Standard Output)
            Error    = [string] (Standard Error)
            ExitCode = [int] (Exit Code)
        }

    .OUTPUTS
            Json     = [PSCustomObject] (JSON Output)
            Output   = [string] (Standard Output)
            Error    = [string] (Standard Error)
            ExitCode = [int] (Exit Code)

    .NOTES
        This function requires ffmpeg to be installed and available in the system PATH.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]$Arguments
    )

    begin {
        foreach ($function in @('Invoke-Process')) {
            $PSDefaultParameterValues["$function`:Verbose"] = $VerbosePreference
            $PSDefaultParameterValues["$function`:Debug"] = $DebugPreference
        }
    }
    process {
        # Check if ffprobe is installed
        Test-FFMpegInstalled -Throw | Out-Null

        $finalArguments = @('-v', 'error', '-of', 'json') + $Arguments
        Write-Verbose "Invoke-FFProbe: Arguments: $($finalArguments -join ' ')"
        $processResult = Invoke-Process ffprobe $finalArguments

        Write-Debug "Invoke-FFProbe: Process exit code: $($processResult.ExitCode)"
        Write-Debug "Invoke-FFProbe: Output length: $($processResult.Output.Length)"
        Write-Debug "Invoke-FFProbe: Error length: $($processResult.Error.Length)"
        if ($processResult.ExitCode -ne 0) {
            Write-Error "Invoke-FFProbe: Failed to execute ffprobe. Exit code: $($processResult.ExitCode)"
            $result = [PSCustomObject]@{
                Json     = $null
                Output   = $processResult.Output
                Error    = $processResult.Error
                ExitCode = $processResult.ExitCode
            }
            return $result
        }

        $json = $processResult.Output | ConvertFrom-Json
        $result = [PSCustomObject]@{
            Json     = $json
            Output   = $processResult.Output
            Error    = $processResult.Error
            ExitCode = $processResult.ExitCode
        }
        return $result
    }
}
