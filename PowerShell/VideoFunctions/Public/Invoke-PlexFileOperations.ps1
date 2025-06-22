function Invoke-PlexFileOperations {
    <#
    .SYNOPSIS
        Invokes all Plex file and folder operations.

    .DESCRIPTION
        This function takes a destination where the Plex movie exists and performs all Plex organization operations.

    .PARAMETER Destination
        Destination path of the Plex bonus content files.

    .EXAMPLE
        Invoke-PlexFileOperations 'C:\plex\movies\My Movie'

        Executes the following commands:
        - Add-PlexFolders $Destination
        - Move-PlexFiles $Destination
        - Remove-PlexEmptyFolders $Destination

    .INPUTS
        [string] - The destination path

    .OUTPUTS
        None. Performs file and folder operations.

    .NOTES
        This function is a convenience wrapper that performs all Plex organization operations in sequence.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    Write-Host "Organizing files in to Plex directory $Destination" -ForegroundColor Green

    try {
        if (-not (Test-Path -Path $Destination)) {
            throw "Destination folder does not exist"
        }

        Add-PlexFolders $Destination
        Move-PlexFiles $Destination   
        Remove-PlexEmptyFolders $Destination
        return
    }
    catch {
        Write-Host $_ -ForegroundColor Red
        return
    }
} 