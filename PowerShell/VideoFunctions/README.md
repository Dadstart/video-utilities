# VideoFunctions PowerShell Module

A PowerShell module for video file processing and Plex folder management. This module provides functions for working with FFmpeg, MKV files, and Plex media organization.

## Features

- **FFmpeg Integration**: Functions for working with FFmpeg and FFprobe
- **MKV Processing**: Extract audio and subtitle tracks from MKV files
- **Media Analysis**: Analyze media streams and properties
- **Plex Organization**: Automate Plex media folder structure and file organization

## Installation

### Prerequisites

- PowerShell 5.1 or higher
- FFmpeg (for FFmpeg-related functions)
- MKVToolNix (for MKV processing functions)

### Quick Installation

1. Clone or download this repository
2. Navigate to the `VideoFunctions` directory
3. Run the installation script:

```powershell
# Install for current user (recommended)
.\Install-VideoFunctions.ps1

# Install for all users (requires elevation)
.\Install-VideoFunctions.ps1 -Scope AllUsers

# Force installation (overwrites existing)
.\Install-VideoFunctions.ps1 -Force
```

### Manual Installation

1. Copy the `VideoFunctions` folder to your PowerShell modules directory:
   - **Windows**: `$env:USERPROFILE\Documents\WindowsPowerShell\Modules\`
   - **PowerShell Core**: `$env:USERPROFILE\Documents\PowerShell\Modules\`

2. Import the module:
   ```powershell
   Import-Module VideoFunctions
   ```

### Uninstallation

To remove the module from your system:

```powershell
# Uninstall from all locations
.\Uninstall-VideoFunctions.ps1

# Uninstall from current user only
.\Uninstall-VideoFunctions.ps1 -Scope CurrentUser

# Uninstall from all users only (requires elevation)
.\Uninstall-VideoFunctions.ps1 -Scope AllUsers
```

## Module Structure

The module follows PowerShell best practices with organized function structure:

```
VideoFunctions/
├── VideoFunctions.psd1          # Module manifest
├── VideoFunctions.psm1          # Root module file
├── Install-VideoFunctions.ps1   # Installation script
├── Uninstall-VideoFunctions.ps1 # Uninstallation script
├── Public/                      # Public functions (exported)
│   ├── Get-FFMpegVersion.ps1
│   ├── Invoke-FFProbe.ps1
│   ├── Get-MkvTrack.ps1
│   ├── Get-MkvTracks.ps1
│   ├── Get-MkvTrackAll.ps1
│   ├── Get-MpegStreams.ps1
│   ├── Add-PlexFolders.ps1
│   ├── Move-PlexFiles.ps1
│   ├── Remove-PlexEmptyFolders.ps1
│   └── Invoke-PlexFileOperations.ps1
├── Private/                     # Private helper functions
│   ├── Test-FFMpegInstalled.ps1
│   ├── Get-FileFromPath.ps1
│   └── Invoke-Process.ps1
└── README.md
```

## Available Functions

### FFmpeg Functions

#### `Get-FFMpegVersion`
Retrieves the version of FFmpeg installed on the system.

```powershell
Get-FFMpegVersion
```

#### `Invoke-FFProbe`
Runs FFprobe with specified arguments and returns parsed JSON output.

```powershell
Invoke-FFProbe '-show_streams', 'video.mp4'
```

### MKV Functions

#### `Get-MkvTrack`
Extracts a single track from an MKV file.

```powershell
Get-MkvTrack 'Movie.mkv' 2 'en.sdh.sup'
```

#### `Get-MkvTracks`
Extracts multiple tracks from an MKV file.

```powershell
Get-MkvTracks 'Movie.mkv' (2,3) 'ac3'
```

#### `Get-MkvTrackAll`
Extracts the same track from multiple MKV files.

```powershell
Get-MkvTrackAll ('Movie.mkv','Film.mkv') 2 'en.sdh.sup'
```

### Media Analysis Functions

#### `Get-MpegStreams`
Retrieves and filters media streams from a file.

```powershell
# Get all audio streams
Get-MpegStreams 'video.mp4' -Type Audio

# Get English subtitle streams
Get-MpegStreams 'video.mp4' -Type Subtitle -Language 'eng'
```

### Plex Functions

#### `Add-PlexFolders`
Creates the standard Plex bonus content folder structure.

```powershell
Add-PlexFolders 'C:\plex\movies\My Movie'
```

#### `Move-PlexFiles`
Moves bonus content files to appropriate Plex folders.

```powershell
Move-PlexFiles 'C:\plex\movies\My Movie'
```

#### `Remove-PlexEmptyFolders`
Removes empty Plex bonus content folders.

```powershell
Remove-PlexEmptyFolders 'C:\plex\movies\My Movie'
```

#### `Invoke-PlexFileOperations`
Performs all Plex organization operations in sequence.

```powershell
Invoke-PlexFileOperations 'C:\plex\movies\My Movie'
```

## Plex Folder Structure

The module creates the following standard Plex bonus content folders:

- **Behind The Scenes** - Files with `-behindthescenes` suffix
- **Deleted Scenes** - Files with `-deleted` suffix
- **Featurettes** - Files with `-featurette` suffix
- **Interviews** - Files with `-interview` suffix
- **Scenes** - Files with `-scene` suffix
- **Shorts** - Files with `-short` suffix
- **Trailers** - Files with `-trailer` suffix
- **Other** - Files with `-other` suffix

## Examples

### Complete Plex Organization Workflow

```powershell
# Import the module
Import-Module VideoFunctions

# Organize a movie directory
Invoke-PlexFileOperations 'C:\plex\movies\The Matrix (1999)'
```

### MKV Track Extraction Workflow

```powershell
# Extract English subtitle track
Get-MkvTrack 'Movie.mkv' 2 'en.sdh.sup'

# Extract multiple audio tracks
Get-MkvTracks 'Movie.mkv' (1,2,3) 'ac3'
```

### Media Analysis

```powershell
# Get all streams in a video file
$streams = Get-MpegStreams 'video.mp4'

# Get only audio streams
$audioStreams = Get-MpegStreams 'video.mp4' -Type Audio

# Get English subtitle streams
$englishSubtitles = Get-MpegStreams 'video.mp4' -Type Subtitle -Language 'eng'
```

## Error Handling

The module includes comprehensive error handling:

- FFmpeg dependency checking
- File existence validation
- Process execution error handling
- Detailed error messages and logging

## Installation Scripts

### Install-VideoFunctions.ps1

The installation script provides the following features:

- **Automatic Detection**: Detects PowerShell version and edition
- **Scope Support**: Install for current user or all users
- **Validation**: Verifies module structure before installation
- **Testing**: Tests module import after installation
- **Error Handling**: Comprehensive error handling and logging
- **WhatIf Support**: Preview installation without executing

**Parameters:**
- `-Scope`: 'CurrentUser' (default) or 'AllUsers'
- `-Force`: Overwrite existing installation
- `-WhatIf`: Preview installation
- `-Confirm`: Prompt for confirmation

### Uninstall-VideoFunctions.ps1

The uninstallation script provides the following features:

- **Complete Removal**: Removes module from all locations
- **Scope Support**: Remove from specific scopes
- **Memory Cleanup**: Removes module from memory if loaded
- **Verification**: Confirms complete removal
- **Safety**: Prompts for confirmation by default

**Parameters:**
- `-Scope`: 'CurrentUser', 'AllUsers', or 'All' (default)
- `-Force`: Skip confirmation prompts
- `-WhatIf`: Preview uninstallation
- `-Confirm`: Prompt for confirmation

## Contributing

[Contributing](/CONTRIBUTING.md)

## License

[Apache License](/LICENSE)

## Version History

[Version History](VERSION.md)

