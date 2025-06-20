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

<#
.SYNOPSIS
    Adds Plex folders for bonus content.

.DESCRIPTION
    This function takes a destination and creates the Plex bonus content folders.

.PARAMETER Destination
    Destination of the folders

.EXAMPLE
    Add-PlexFolders 'C:\plex\movies\My Movie'

    Creates folder 'C:\plex\movies\My Movie\Behind The Scenes'
    Creates folder 'C:\plex\movies\My Movie\Deleted Scenes'
    etc.

.INPUTS
    [string]
#>
function Add-PlexFolders {
    param (
        [Parameter(Mandatory)]
        [string]$destination
    )

    if (-not (Test-Path -Path $destination)) {
        throw "Destination folder does not exist";
    }

    foreach ($folder in $plexLayout.Keys) {
        $path = "$destination\$folder";
        if (-not (Test-Path -Path $path)) {
            New-Item -Path $path -ItemType Directory;
        }
    }

    Write-Host "Plex folders created" -ForegroundColor Blue;
}

<#
.SYNOPSIS
    Moves bonus content to Plex folders.

.DESCRIPTION
    This function takes a destination and moves all bonus content in the current directory to the Plex bonus content folders.

.PARAMETER Destination
    Destination of the bonus content

.EXAMPLE
    Move-PlexFiles 'C:\plex\movies\My Movie'

    Moves *-behindthescenes.* to 'C:\plex\movies\My Movie\Behind The Scenes'
    Moves *-deleted.* to 'C:\plex\movies\My Movie\Deleted Scenes'
    etc.

.INPUTS
    [string]
#>
function Move-PlexFiles {
    param (
        [Parameter(Mandatory)]
        [string]$destination
    )

    if (-not (Test-Path -Path $destination)) {
        throw "Destination folder does not exist";
    }

    $currentDir = (Get-Location).Path;
    if (-not $currentDir.EndsWith("MP4")) {
        throw "Must be in MP4 directory";
    }

    foreach ($folder in $plexLayout.Keys) {
        $fileSuffix = $plexLayout[$folder];
        $destFiles = "*-$fileSuffix*";
        $destFolder = "$destination\$folder";
        Write-Host "Moving -$fileSuffix to $destFolder";
        Get-ChildItem $destFiles | ForEach-Object {
            Move-Item $_.Name "$destFolder";
        }
    }

    Write-Host "Files moved to Plex folders" -ForegroundColor Blue;
}

<#
.SYNOPSIS
    Removes empty Plex folders for bonus content.

.DESCRIPTION
    This function takes a destination where the Plex folders exist

.PARAMETER Destination
    Destination of the folders

.EXAMPLE
    Remove-PlexEmptyFolders 'C:\plex\movies\My Movie'

    Removes the folder 'C:\plex\movies\My Movie\Behind The Scenes' if it is empty
    Creates folder 'C:\plex\movies\My Movie\Deleted Scenes' if it is empty
    etc.

.INPUTS
    [string]
#>
function Remove-PlexEmptyFolders {
    param (
        [Parameter(Mandatory)]
        [string]$destination
    )

    if (-not (Test-Path -Path $destination)) {
        throw "Destination folder does not exist";
    }

    $foldersDeleted = 0;
    foreach ($folder in $plexLayout.Keys) {
        $path = "$destination\$folder";

        if (-not (Test-Path -Path $path)) {
            continue;
        }

        if ((Get-ChildItem $path).Count -eq 0) {
            $foldersDeleted++;
            Remove-Item -Path $path;
        }
    }

    Write-Host "$foldersDeleted empty Plex folders deleted" -ForegroundColor Blue;
}

<#
.SYNOPSIS
    Invokes all Plex file and folder operations

.DESCRIPTION
    This function takes a destination where the Plex movie exists

.PARAMETER Destination
    Destination of the Plex bonus content files

.EXAMPLE
    Invoke-PlexFileOperations 'C:\plex\movies\My Movie'

    Executes the following commands:
    - Add-PlexFolders $Destination
    - Move-PlexFiles $Destination
    - Remove-PlexEmptyFolders $Destination

.INPUTS
    [string]
#>
function Invoke-PlexFileOperations {
    param (
        [Parameter(Mandatory)]
        [string]$destination
    )

    Write-Host "Organizing files in to Plex directory $destination" -ForegroundColor Green;

    try {
        if (-not (Test-Path -Path $destination)) {
            throw "Destination folder does not exist";
        }

        Add-PlexFolders $destination;
        Move-PlexFiles $destination;   
        Remove-PlexEmptyFolders $destination;
        return;
    }
    catch {
        Write-Host $_ -ForegroundColor Red;
        return;
    }
}
