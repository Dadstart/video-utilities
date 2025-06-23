function Move-PlexFiles {
    <#
    .SYNOPSIS
        Moves bonus content to Plex folders.

    .DESCRIPTION
        This function takes a destination and moves all bonus content in the current directory to the Plex bonus content folders.

    .PARAMETER Destination
        Destination path where the bonus content should be moved.

    .EXAMPLE
        Move-PlexFiles 'C:\plex\movies\My Movie'

        Moves *-behindthescenes.* to 'C:\plex\movies\My Movie\Behind The Scenes'
        Moves *-deleted.* to 'C:\plex\movies\My Movie\Deleted Scenes'
        etc.

    .INPUTS
        [string] - The destination path

    .OUTPUTS
        None. Moves files to appropriate Plex folders.

    .NOTES
        This function looks for files with specific suffixes in the current directory and moves them to appropriate Plex folders.
    #>
    [CmdletBinding()]
    [OutputType([void])]
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

    foreach ($folder in $plexLayout.Keys) {
        $fileSuffix = $plexLayout[$folder]
        $destFiles = (Get-ChildItem -Recurse "*-$fileSuffix.mp4") + (Get-ChildItem -Recurse "*-$fileSuffix.srt")
        $destFolder = "$Destination\$folder"
        Write-Host "Moving -$fileSuffix to $destFolder"
        foreach ($destFile in $destFiles) {
            Move-Item $destFile.Name "$destFolder"
        }
    }

    Write-Host "Files moved to Plex folders" -ForegroundColor Blue
} 