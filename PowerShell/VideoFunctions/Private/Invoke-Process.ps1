function Invoke-Process {
    <#
    .SYNOPSIS
        Invokes a process with the specified arguments.

    .DESCRIPTION
        This function invokes a process with the specified arguments and returns the output.
        It provides better error handling and output capture than the standard Start-Process.

    .PARAMETER Name
        The name of the process to invoke.

    .PARAMETER Arguments
        The arguments to pass to the process.

    .EXAMPLE
        Invoke-Process 'ffprobe' @('-version')

        Invokes ffprobe with the -version argument and returns the output.

    .OUTPUTS
        [string]
        Returns the output of the process.

    .NOTES
        This is an internal helper function used by other module functions.
        It provides better error handling and output capture than standard PowerShell process invocation.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory = $false, Position = 1)]
        [string[]]$Arguments = @()
    )

    # Setup process start information
    # $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi = New-Object System.Diagnostics.ProcessStartInfo -Property @{
        FileName     = $Name
        CreateNoWindow = $true
        UseShellExecute = $false
        RedirectStandardOutput = $true
        RedirectStandardError = $true
        WorkingDirectory = (Get-Location).Path
    }

    foreach ($arg in $Arguments) {
        [void]$psi.ArgumentList.Add($arg)
    }

    Write-Verbose "Invoke-Process: Process Info: FileName: $($psi.FileName) Arguments: $($psi.ArgumentList)"

    # Create process object
    $process = New-Object -TypeName System.Diagnostics.Process
    $process.StartInfo = $psi

    # Start the process
    Write-Verbose "Invoke-Process: Starting Process"
    $process.Start() | Out-Null
    $standardOutput = $process.StandardOutput.ReadToEnd()
    $standardError = $process.StandardError.ReadToEnd()

    # Wait for the process to exit
    Write-Verbose "Invoke-Process: Waiting for Process to Exit"
    $process.WaitForExit()
    Write-Verbose "Invoke-Process: Process Exited (ExitCode: $($process.ExitCode))"

    # Check for errors
    if ($process.ExitCode -ne 0) {
        Write-Warning "Process Failed`n`tExecutable: $Name`n`tArguments: $Arguments`n`tExit Code: $($process.ExitCode)`n`tError: $standardError"
        throw $standardError.Trim()
    } elseif ($standardError.Length -gt 0) {
        Write-Warning "Process Error Output: $($standardError.Trim())"
    }

    return $standardOutput
}