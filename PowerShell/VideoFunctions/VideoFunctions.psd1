@{
    ModuleVersion = '1.0.0'
    GUID = 'd1e8f8b2-4b8e-4c5e-9c1d-1e1f5e1e1e1e'
    Author = 'Andrew Bishop'
    Copyright = 'Copyright © Andrew Bishop 2025'
    Description = 'A PowerShell module for video file processing and Plex folder management.'
    FunctionsToExport = @(
        'Get-MkvTrack',
        'Get-MkvTracks',
        'Get-MkvTrackAll',
        'Add-PlexFolders',
        'Move-PlexFiles',
        'Remove-PlexEmptyFolders',
        'Invoke-PlexFileOperations'
    )
    PowerShellVersion = '5.1'
    RequiredModules = @()
    FileList = @()
}