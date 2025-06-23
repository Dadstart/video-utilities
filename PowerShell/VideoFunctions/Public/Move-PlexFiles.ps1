function Move-PlexFile {
    <#
    .SYNOPSIS
        Moves bonus content to Plex folders.

    .DESCRIPTION
        This function takes a destination and moves all bonus content in the current directory to the Plex bonus content folders.

    .PARAMETER Destination
        Destination path where the bonus content should be moved.

    .EXAMPLE
        Move-PlexFile 'C:\plex\movies\My Movie'

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
        Write-Error "Destination folder does not exist" -ErrorAction Stop
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

    $filesMoved = 0
    foreach ($folder in $plexLayout.Keys) {
        $fileSuffix = $plexLayout[$folder]
        $destFiles = (Get-ChildItem -Recurse "*-$fileSuffix.mp4") + (Get-ChildItem -Recurse "*-$fileSuffix.srt")
        $destFolder = Join-Path -Path $Destination -ChildPath $folder
        Write-Output "Moving -$fileSuffix to $destFolder"
        foreach ($destFile in $destFiles) {
            Move-Item $destFile.Name "$destFolder"
            $filesMoved++
        }
    }

    if ($filesMoved -eq 0) {
        Write-Warning "No bonus content files found to move in current directory"
    } else {
        Write-Information "$filesMoved files moved to Plex folders" -InformationAction Continue
    }
}