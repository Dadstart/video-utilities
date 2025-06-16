# ls Star* | % { Get-Pgs $_.Name 9 -sdh }

Write-Host "Loading Video PowerShell Functions" -ForegroundColor Green

<#
.SYNOPSIS
    Extracts an audio or subtitle track from an MKV.

.DESCRIPTION
    This function takes an MKV, track number and extracts it appending the specified extension.

.PARAMETER Name
    File name of the MKV file.

.PARAMETER Track
    Track number to extract.

.PARAMETER Extension
    File extension to append to the track output.

.EXAMPLE
    Get-MkvTrack 'Move.mkv' 2 en.sdh.sup

    Outputs track 2 to 'Movie.en.sdh.sup'

.INPUTS
    [string]
    [int]
    [string]
#>
function Get-MkvTrack {
    param (
        [Parameter(Mandatory)]
        [string]$name,
        [Parameter(Mandatory)]
        [int]$track,
        [Parameter(Mandatory)]
        [string]$extension
    )

    if ($name.EndsWith(".mkv")) { $name = $name.Substring(0, $name.Length - 4); };
    Write-Host "Extracting track $track from '$name.mkv'" -ForegroundColor Blue;

    $outputName = "$name.$extension";
    mkvextract "$name.mkv" tracks $track`:"$outputName";

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed ($LASTEXITCODE)" -ForegroundColor Red;
        exit $LASTEXITCODE;
    }
    else {
        Write-Host "Complete" -ForegroundColor Blue;
    }
}

<#
.SYNOPSIS
    Extracts multiple audio or subtitle tracks from an MKV.

.DESCRIPTION
    This function takes an MKV, a list of track numbers and extracts them appending the specified extension.

.PARAMETER Name
    File name of the MKV file.

.PARAMETER Track
    Array of track numbers to extract.

.PARAMETER Extension
    File extension to append to the track output.

.EXAMPLE
    Get-MkvTracks 'Move.mkv' (2,3) ac3

    Outputs track 2 to 'Movie.2.ac3'
    Outputs track 3 to 'Movie.3.ac3'

.INPUTS
    [string]
    [int[]]
    [string]
#>
function Get-MkvTracks {
    param (
        [Parameter(Mandatory)]
        [string]$name,
        [Parameter(Mandatory)]
        [int[]]$tracks,
        [Parameter(Mandatory)]
        [string]$extension
    )

    foreach ($track in $tracks) {
        $finalExtension = "$track.$extension";
        Get-MkvTrack $name $track $finalExtension;
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE;
        }
    }
}

<#
.SYNOPSIS
    Extracts an audio or subtitle track from multiplle files.

.DESCRIPTION
    This function takes list of MKV filse, a track number and extracts them appending the specified extension.

.PARAMETER Names
    Files name of the MKV file.

.PARAMETER Track
    Track number to extract.

.PARAMETER Extension
    File extension to append to the track outputs.

.EXAMPLE
    Get-MkvTrackAll ('Move.mkv','Film.mkv') 2 en.sdh.sup

    Outputs track 2 from 'Move.mkv' to 'Movie.en.sdh.sup'
    Outputs track 2 from 'Film.mkv' to 'Film.en.sdh.sup'

.INPUTS
    [string[]]
    [int]
    [string]
#>
function Get-MkvTrackAll {
    param (
        [Parameter(Mandatory)]
        [string[]]$names,
        [Parameter(Mandatory)]
        [int]$track,
        [Parameter(Mandatory)]
        [string]$extension
    )

    foreach ($name in $names) {
        Get-MkvTrack "$name" @($track) $extension -NoTrackExtension;
    }
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
Set-Variable -Name plexLayout -Option ReadOnly

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
        Write-Host "Destination folder does not exist" -ForegroundColor Red;
        exit 1;
    }

    foreach ($folder in $plexLayout) {
        $path = "$destination\$folder";
        if (-not (Test-Path -Path $path)) {
            New-Item -Path $path -ItemType Directory;
        }
    }

    Write-Host '$plexLayout.Count folders created' -ForegroundColor Blue;
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
        Write-Host "Destination folder does not exist" -ForegroundColor Red;
        exit 1;
    }

    $currentDir = (Get-Location).Path;
    if ($currentDir.EndsWith("MP4")) {
        Write-Host "Must be in MP4 directory" -ForegroundColor Red;
        exit 1;
    }

    $fileCount = 0;
    foreach ($folder in $plexLayout.Keys) {
        $fileSuffix = $plexLayout[$folder];
        $destFiles = "*-$fileSuffix*";
        $destFolder = "$destination\$folder";
        Write-Host "Moving -$fileSuffix to $destFolder";
        $fileCount += (Get-ChildItem $destFiles).Count;
        Move-Item "destFiles" "$destFolder";
    }

    Write-Host '$fileCount files moved to Plex folders' -ForegroundColor Blue;
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
        Write-Host "Destination folder does not exist" -ForegroundColor Red;
        exit 1;
    }


    foreach ($folder in $plexLayout) {
        $path = "$destination\$folder";

        if (-not (Test-Path -Path $path)) {
            return;
        }

        $foldersDeleted = 0;
        $filesToDelete = "$path\*";
        $fileCount = (Get-ChildItem $filesToDelete).Count;
        if ($fileCount -ne 0) {
            $foldersDeleted++;
            Remove-Item -Path $filesToDelete;
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

    Executes the following commands
    Add-PlexFolders $Destination
    Move-PlexFiles $Destination
    Remove-PlexEmptyFolders $Destination

.INPUTS
    [string]
#>
function Invoke-PlexFileOperations {
    param (
        [Parameter(Mandatory)]
        [string]$destination
    )

    Write-Host "Organizing files in to Plex directory $destination" -ForegroundColor Green;

    if (-not (Test-Path -Path $destination)) {
        Write-Host "Destination folder does not exist" -ForegroundColor Red;
        exit 1;
    }

    Add-PlexFolders $destination;
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE;
    }
   
    Move-PlexFiles $destination;
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE;
    }
   
    Remove-PlexEmptyFolders $destination;
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE;
    }
}