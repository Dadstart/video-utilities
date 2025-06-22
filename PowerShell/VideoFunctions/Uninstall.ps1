#!/usr/bin/env pwsh

try {
    Push-Location $PSScriptRoot;
    Remove-Module VideoFunctions -Force;
    Pop-Location;
} catch {
    Write-Error "Uninstall failed: $($_.Exception.Message)";
    exit 1;
}
