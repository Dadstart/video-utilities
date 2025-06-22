#!/usr/bin/env pwsh

try {
    Push-Location $PSScriptRoot;
    if ($null -ne (Get-Module VideoFunctions)) {
        .\Uninstall-VideoFunctions.ps1;
    }
    .\Install-VideoFunctions.ps1;
    Pop-Location;
} catch {
    Write-Error "Reinstall failed: $($_.Exception.Message)";
    exit 1;
}
