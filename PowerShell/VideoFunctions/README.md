# Video Functions PowerShell Module

## Overview
The Video Functions module provides a set of PowerShell functions designed to facilitate the extraction of audio and subtitle tracks from MKV files, as well as manage Plex folder structures for bonus content. This module is particularly useful for users who want to organize their video files and associated content efficiently.

## Functions
The module includes the following functions:

- **Get-MkvTrack**: Extracts a specific audio or subtitle track from an MKV file.
- **Get-MkvTracks**: Extracts multiple audio or subtitle tracks from a single MKV file.
- **Get-MkvTrackAll**: Extracts a specific track from multiple MKV files.
- **Add-PlexFolders**: Creates a set of predefined Plex folder structures for organizing bonus content.
- **Move-PlexFiles**: Moves bonus content files into their respective Plex folders based on naming conventions.
- **Remove-PlexEmptyFolders**: Deletes any empty Plex folders that may have been created.
- **Invoke-PlexFileOperations**: Executes a series of operations to organize Plex content in a specified directory.

## Installation
To install the Video Functions module, clone the repository or download the files and place them in a directory of your choice. Import the module in your PowerShell session using the following command:

```powershell
Import-Module 'path\to\VideoFunctions\VideoFunctions.psm1'
```

## Usage
Here are some examples of how to use the functions in this module:

### Extract a Track from an MKV File
```powershell
Get-MkvTrack 'Movie.mkv' 2 'en.sdh.sup'
```

### Extract Multiple Tracks from an MKV File
```powershell
Get-MkvTracks 'Movie.mkv' @(2, 3) 'ac3'
```

### Create Plex Folders
```powershell
Add-PlexFolders 'C:\plex\movies\My Movie'
```

### Move Bonus Content to Plex Folders
```powershell
Move-PlexFiles 'C:\plex\movies\My Movie'
```

### Remove Empty Plex Folders
```powershell
Remove-PlexEmptyFolders 'C:\plex\movies\My Movie'
```

### Invoke All Plex File Operations
```powershell
Invoke-PlexFileOperations 'C:\plex\movies\My Movie'
```

## Contributing
Contributions to the Video Functions module are welcome. Please submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.