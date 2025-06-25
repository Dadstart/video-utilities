function Move-PlexFile {
    <#
    .SYNOPSIS
        Moves bonus content to Plex folders.

    .DESCRIPTION
        This function takes a source and destination and moves all bonus content in the source directory to the Plex bonus content folders in the destination.

    .PARAMETER Source
        Source path where the bonus content files are located.

    .PARAMETER Destination
        Destination path where the bonus content should be moved.

    .EXAMPLE
        Move-PlexFile -Source 'C:\downloads\My Movie' -Destination 'C:\plex\movies\My Movie'

        Moves *-behindthescenes.* from source to 'C:\plex\movies\My Movie\Behind The Scenes'
        Moves *-deleted.* from source to 'C:\plex\movies\My Movie\Deleted Scenes'
        etc.

    .INPUTS
        [string] - The source and destination paths

    .OUTPUTS
        None. Moves files to appropriate Plex folders.

    .NOTES
        This function looks for files with specific suffixes in the source directory and moves them to appropriate Plex folders.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    if (-not (Test-Path -Path $Destination)) {
        Write-Error "Destination folder does not exist" -ErrorAction Stop
    }
    if (-not (Test-Path -Path $Source)) {
        Write-Error "Source folder does not exist" -ErrorAction Stop
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
        $destFiles = (Get-ChildItem -Path $Source -Recurse -Filter "*-$fileSuffix.mp4") + (Get-ChildItem -Path $Source -Recurse -Filter "*-$fileSuffix.srt")
        $destFolder = Join-Path -Path $Destination -ChildPath $folder
        Write-Output "Moving -$fileSuffix to $destFolder"
        foreach ($destFile in $destFiles) {
            Move-Item $destFile.FullName "$destFolder"
            $filesMoved++
        }
    }

    if ($filesMoved -eq 0) {
        Write-Warning "No bonus content files found to move in source directory $Source"
    } else {
        Write-Information "$filesMoved files moved to Plex folders" -InformationAction Continue
    }
}