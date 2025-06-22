#
# Contains internal functions for ffmpeg and it's tools (ffplay, ffprobe, etc.)
#

function Test-FFMpegInstalled {
    <#
    .SYNOPSIS
    Checks if ffmpeg is installed on the system.

    .PARAMETER Throw
    Throw if ffmpeg is not installed.

    .OUTPUTS
    [System.Management.Automation.ApplicationInfo]
    Returns an object containing the properties including Name and Path

    .DESCRIPTION
    This function checks if ffmpeg is available in the system's PATH.
    It returns $true if ffmpeg is found, otherwise it returns $false.

    .EXAMPLE
    Test-FFMpegInstalled

    Returns $true if ffmpeg is installed, otherwise $false.
    #>
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $false)]
        [boolean]$throw = $true
    )

    $test = Get-FileFromPath -Name 'ffmpeg';

    if ($null -ne $test) {
        return $true;
    }
    elseif ($throw) {
        throw "ffmpeg is not installed or not found in the system PATH.";
    }
    else {
        return $false;
    }
}

function Invoke-FFProbe {
    <#
    .SYNOPSIS
    Retrieves an object converted from the JSON output from ffprobe.

    .PARAMETER Arguments
    Arguments to pass to ffprobe.

    .OUTPUTS
    [System.Management.Automation.PSCustomObject]
    Returns a custom object with the parsed results from the JSON output from ffprobe.

    .DESCRIPTION
    This function runs ffprobe on the specified media file and returns the object
    parsed from the JSON format.
    
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

    #>
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]$arguments
    )

    # Check if ffmpeg is installed
    Test-FFMpegInstalled | Out-Null;

    $finalArguments = @('-v error', '-of json') + $arguments;
    Write-Verbose "Invoke-FFProbe: Arguments: $($finalArguments -join ' ')";
    $json = Invoke-Process ffprobe $finalArguments;
    $result = $json | ConvertFrom-Json;

    return $result;
}

function Get-FFMpegVersion {
    <#
    .SYNOPSIS
    Retrieves the version of ffmpeg installed on the system.

    .DESCRIPTION
    This function checks if ffmpeg is available in the system's PATH and returns its version.
    If ffmpeg is not found, it throws an error.

    .EXAMPLE
    Get-FfmpegVersion

    Returns the version of ffmpeg installed on the system, ex. '7.1.1-full_build-www.gyan.dev'
    #>

    Test-FFMpegInstalled -throw $true | Out-Null;
    
    $result = Invoke-FFProbe '-show_program_version';
#    $result = & ffprobe -v error -of json -show_program_version | ConvertFrom-Json;
#    $result = & ffprobe -v 0 -of json -show_program_version | ConvertFrom-Json;

    return $result.program_version.version;
}
