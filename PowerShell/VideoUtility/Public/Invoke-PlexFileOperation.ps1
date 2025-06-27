function Invoke-PlexFileOperation {
    <#
    .SYNOPSIS
        Invokes all Plex file and folder operations.

    .DESCRIPTION
        This function takes a source and destination where the Plex movie exists and performs all Plex organization operations.

    .PARAMETER Source
        Source path where the bonus content files are located.

    .PARAMETER Destination
        Destination path of the Plex bonus content files.

    .EXAMPLE
        Invoke-PlexFileOperation -Source 'C:\downloads\My Movie' -Destination 'C:\plex\movies\My Movie'

        Executes the following commands:
        - Add-PlexFolder $Destination
        - Move-PlexFile -Source $Source -Destination $Destination
        - Remove-PlexEmptyFolder $Destination

    .INPUTS
        [string] - The source and destination paths

    .OUTPUTS
        None. Performs file and folder operations.

    .NOTES
        This function is a convenience wrapper that performs all Plex organization operations in sequence.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    Write-Information "Organizing files from $Source into Plex directory $Destination"

    try {
        if (-not (Test-Path -Path $Destination)) {
            Write-Error 'Destination folder does not exist' -ErrorAction Stop
        }
        if (-not (Test-Path -Path $Source)) {
            Write-Error 'Source folder does not exist' -ErrorAction Stop
        }

        Add-PlexFolder $Destination
        Move-PlexFile -Source $Source -Destination $Destination
        Remove-PlexEmptyFolder $Destination
        return
    }
    catch {
        Write-Error $_
        return
    }
}