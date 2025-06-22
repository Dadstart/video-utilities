#!/usr/bin/env pwsh

try {
    Push-Location $PSScriptRoot;
    Import-Module $PSScriptRoot\. -Force;
    Pop-Location;
} catch {
    Write-Error "Install failed: $($_.Exception.Message)";
    exit 1;
}
