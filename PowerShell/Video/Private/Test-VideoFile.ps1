function Test-VideoFile {
    <#
    .SYNOPSIS
        Tests if a file is a valid video file.

    .DESCRIPTION
        Validates that a file exists and has a video file extension.
        This is a private helper function used by other functions in the module.

    .PARAMETER Path
        The path to the file to test.

    .PARAMETER SupportedExtensions
        Array of supported video file extensions. Defaults to common video formats.

    .EXAMPLE
        Test-VideoFile -Path "C:\Videos\sample.mp4"
        
        Returns $true if the file is a valid video file.

    .INPUTS
        System.String

    .OUTPUTS
        System.Boolean

    .NOTES
        This is a private helper function and should not be called directly.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string[]]$SupportedExtensions = @('.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.3gp', '.ogv')
    )

    try {
        # Check if file exists
        if (-not (Test-Path -Path $Path -PathType Leaf)) {
            Write-Verbose "File does not exist: $Path"
            return $false
        }

        # Get file extension
        $extension = [System.IO.Path]::GetExtension($Path).ToLower()
        
        # Check if extension is supported
        if ($extension -in $SupportedExtensions) {
            Write-Verbose "File is a supported video format: $Path"
            return $true
        }
        else {
            Write-Verbose "File extension not supported: $extension"
            return $false
        }
    }
    catch {
        Write-Verbose "Error testing video file '$Path': $($_.Exception.Message)"
        return $false
    }
} 