function Get-VideoInfo {
    <#
    .SYNOPSIS
        Gets information about a video file.

    .DESCRIPTION
        Retrieves basic information about a video file including file size, creation date, and other properties.
        This is a sample function to demonstrate the module structure.

    .PARAMETER Path
        The path to the video file to analyze.

    .PARAMETER IncludeDetails
        Include additional detailed information about the file.

    .EXAMPLE
        Get-VideoInfo -Path "C:\Videos\sample.mp4"
        
        Gets basic information about the specified video file.

    .EXAMPLE
        Get-VideoInfo -Path "C:\Videos\sample.mp4" -IncludeDetails
        
        Gets detailed information about the specified video file.

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        This is a sample function for demonstration purposes.
        Future versions will include actual video metadata extraction.

    .LINK
        https://github.com/your-repo/video-utilities
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, 
                   Position = 0,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true,
                   HelpMessage = "Path to the video file")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [Alias("FullName")]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeDetails
    )

    begin {
        Write-Verbose "Starting video information retrieval"
    }

    process {
        try {
            $fileInfo = Get-Item -Path $Path -ErrorAction Stop
            
            # Basic information object
            $videoInfo = [PSCustomObject]@{
                Name = $fileInfo.Name
                FullName = $fileInfo.FullName
                Size = $fileInfo.Length
                SizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
                CreationTime = $fileInfo.CreationTime
                LastWriteTime = $fileInfo.LastWriteTime
                Extension = $fileInfo.Extension
                Directory = $fileInfo.DirectoryName
            }

            if ($IncludeDetails) {
                # Add additional properties for detailed information
                $videoInfo | Add-Member -MemberType NoteProperty -Name "Attributes" -Value $fileInfo.Attributes
                $videoInfo | Add-Member -MemberType NoteProperty -Name "IsReadOnly" -Value $fileInfo.IsReadOnly
                $videoInfo | Add-Member -MemberType NoteProperty -Name "LastAccessTime" -Value $fileInfo.LastAccessTime
            }

            Write-Verbose "Successfully retrieved information for: $($fileInfo.Name)"
            return $videoInfo
        }
        catch {
            Write-Error "Failed to retrieve video information for '$Path': $($_.Exception.Message)"
            throw
        }
    }

    end {
        Write-Verbose "Completed video information retrieval"
    }
} 