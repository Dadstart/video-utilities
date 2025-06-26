# Video PowerShell Module

A PowerShell module for video processing and manipulation utilities. This module provides functions for working with video files, media analysis, and processing.

## Features

- **Video Processing**: Functions for video file manipulation and conversion
- **Media Analysis**: Analyze video properties and metadata
- **File Management**: Utilities for video file organization and management
- **Modern PowerShell**: Built for PowerShell 7.0+ with modern features

## Requirements

- PowerShell 7.0 or higher
- Windows, macOS, or Linux (cross-platform support)

## Installation

### Manual Installation

1. Clone or download this repository
2. Copy the `Video` folder to your PowerShell modules directory:
   - **Windows**: `$env:USERPROFILE\Documents\PowerShell\Modules\`
   - **macOS/Linux**: `$HOME/.local/share/powershell/Modules/`
3. Import the module: `Import-Module Video`

### From PowerShell Gallery (Future)

```powershell
Install-Module -Name Video -Repository PSGallery
```

## Module Structure

The module follows PowerShell best practices with organized function structure:

```
Video/
├── Video.psd1              # Module manifest
├── Video.psm1              # Root module file
├── README.md               # This file
├── Public/                 # Public functions (exported)
│   └── (function files)
├── Private/                # Private helper functions
│   └── (helper files)
└── Tests/                  # Pester test files (future)
    └── (test files)
```

## Available Functions

*Functions will be added as the module develops*

## Examples

### Basic Usage

```powershell
# Import the module
Import-Module Video

# List available functions
Get-Command -Module Video
```

## Development

### Adding New Functions

1. **Public Functions**: Place in the `Public/` directory
2. **Private Functions**: Place in the `Private/` directory
3. **Update Module Files**: Add function names to `Video.psm1` and `Video.psd1`

### Function Template

```powershell
function Verb-Noun {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Parameter1,
        
        [Parameter()]
        [switch]$SwitchParameter
    )
    
    begin {
        # Setup code
    }
    
    process {
        # Main processing logic
    }
    
    end {
        # Cleanup code
    }
}
```

## Error Handling

The module includes comprehensive error handling:

- Parameter validation
- File existence checks
- Detailed error messages
- Proper exception handling

## Contributing

1. Follow PowerShell best practices
2. Include comprehensive help documentation
3. Add Pester tests for new functions
4. Update this README with new features

## License

Copyright © Andrew Bishop 2024

## Version History

- **1.0.0** - Initial release 