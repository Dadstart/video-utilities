#
# Utilties
#
function Get-FileFromPath {
    <#
    .SYNpsiS
    Checks if a path is available in the current environment paths.

    .DESCRIPTION
    This function checks if the file exists and returns the file information if it does.

    .PARAMETER Name
    The file to check.

    .OUTPUTS
    [System.Management.Automation.ApplicationInfo]
    Returns an object containing the properties including Name and Path

    .EXAMPLE
    Get-FileFromPath -Name 'explorer'

    Returns an [ApplicationInfo] for 'explorer.exe'.

    .EXAMPLE
    Get-FileFromPath -Name 'bogusfile'

    Returns $null if 'bogusfile' does not exist in the current environment paths.
    #>
    [OutputType([System.Management.Automation.ApplicationInfo])]
    
    param (
        [Parameter(Mandatory = $true)]
        [string]$name
    )

    Get-Command -Name $name -ErrorAction SilentlyContinue -CommandType Application -TotalCount 1;
    return $cmd;
}

function Invoke-Process {
    <#
    .SYNOPSIS
    Invokes a process with the specified arguments.

    .PARAMETER Name
    The name of the process to invoke.

    .PARAMETER Arguments
    The arguments to pass to the process.

    .OUTPUTS
    [string]
    Returns the output of the process.
    #>
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$name,
        [Parameter(Mandatory = $false, Position = 1)]
        [string[]]$arguments = @()
    )

    # Setup process start information
    $psi = New-Object System.Diagnostics.ProcessStartInfo;
    $psi.CreateNoWindow = $true;
    $psi.UseShellExecute = $false;
    $psi.RedirectStandardOutput = $true;
    $psi.RedirectStandardError = $true;
    $psi.WorkingDirectory = $PWD.Path; # Use current working directory
    $psi.FileName = $name;
    $psi.Arguments = $arguments -join ' ';
    Write-Verbose "Invoke-Process: Process Info: $($psi.FileName) $($psi.Arguments)";

    # Create process object
    $process = New-Object -TypeName System.Diagnostics.Process;
    $process.StartInfo = $psi;

    # Start the process
    Write-Verbose "Invoke-Executable: Starting Process";
    $process.Start() | Out-Null;
    $standardOutput = $process.StandardOutput.ReadToEnd();
    $standardError = $process.StandardError.ReadToEnd();

    # Wait for the process to exit
    Write-Verbose "Invoke-Executable: Waiting for Process to Exit";
    $process.WaitForExit();
    Write-Verbose "Invoke-Executable: Process Exited (ExitCode: $($process.ExitCode))";

    # Check for errors
    if ($process.ExitCode -ne 0) {
        Write-Debug "Process Failed`n`tExecutable: $name`n`tArguments: $arguments`n`tExit Code: $($process.ExitCode)`n`tError: $standardError";
        throw $standardError.Trim();
    } elseif ($errorOutput.Length -gt 0) {
        Write-Warning "Process Error Output: $($standardError.Trim())";
    }

    return $standardOutput;
}