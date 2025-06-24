function Invoke-PlexFileOperation {
    <#
    .SYNOPSIS
        Invokes all Plex file and folder operations.

    .DESCRIPTION
        This function takes a destination where the Plex movie exists and performs all Plex organization operations.

    .PARAMETER Destination
        Destination path of the Plex bonus content files.

    .EXAMPLE
        Invoke-PlexFileOperation 'C:\plex\movies\My Movie'

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
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    Write-Information "Organizing files in to Plex directory $Destination" -InformationAction Continue

    try {
        if (-not (Test-Path -Path $Destination)) {
            Write-Error "Destination folder does not exist" -ErrorAction Stop
        }

        Add-PlexFolder $Destination
        Move-PlexFile $Destination
        Remove-PlexEmptyFolder $Destination
        return
    }
    catch {
        Write-Error $_
        return
    }
}