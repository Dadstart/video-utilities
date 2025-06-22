function Remove-PlexEmptyFolders {
    <#
    .SYNOPSIS
        Removes empty Plex folders for bonus content.

    .DESCRIPTION
        This function takes a destination where the Plex folders exist and removes any that are empty.

    .PARAMETER Destination
        Destination path where the Plex folders exist.

    .EXAMPLE
        Remove-PlexEmptyFolders 'C:\plex\movies\My Movie'

        Removes the folder 'C:\plex\movies\My Movie\Behind The Scenes' if it is empty
        Removes the folder 'C:\plex\movies\My Movie\Deleted Scenes' if it is empty
        etc.

    .INPUTS
        [string] - The destination path

    .OUTPUTS
        None. Removes empty directories.

    .NOTES
        This function only removes Plex bonus content folders that are completely empty.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    if (-not (Test-Path -Path $Destination)) {
        throw "Destination folder does not exist"
    }

    $plexLayout = @{
        'Behind The Scenes' = 'behindthescenes'
        'Deleted Scenes'    = 'deleted'
        'Featurettes'       = 'featurette'
        'Interviews'        = 'interview'
        'Scenes'            = 'scene'
        'Shorts'            = 'short'
        'Trailers'          = 'trailer'
        'Other'             = 'other'
    }

    $foldersDeleted = 0
    foreach ($folder in $plexLayout.Keys) {
        $path = "$Destination\$folder"

        if (-not (Test-Path -Path $path)) {
            continue
        }

        if ((Get-ChildItem $path).Count -eq 0) {
            $foldersDeleted++
            Remove-Item -Path $path
        }
    }

    Write-Host "$foldersDeleted empty Plex folders deleted" -ForegroundColor Blue
} 