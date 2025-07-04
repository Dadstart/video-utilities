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

    .RETURNVALUE
        [PSCustomObject]@{
            Output   = [string] (Standard Output)
            Error    = [string] (Standard Error)
            ExitCode = [int] (Exit Code)
        }

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
        FileName               = $Name
        CreateNoWindow         = $true
        UseShellExecute        = $false
        RedirectStandardOutput = $true
        RedirectStandardError  = $true
        WorkingDirectory       = (Get-Location).Path
    }

    $psi.Arguments = $Arguments -join ' '

    Write-Verbose "Invoke-Process: Process Info: FileName: $($psi.FileName) Arguments: $($psi.ArgumentList)"

    # Create process object
    $process = New-Object -TypeName System.Diagnostics.Process
    $process.StartInfo = $psi

    # Start the process
    Write-Verbose 'Invoke-Process: Starting Process'
    $process.Start() | Out-Null

    # Read output streams asynchronously to prevent deadlocks
    Write-Verbose 'Invoke-Process: Reading Output Streams'
    $outputJob = $process.StandardOutput.ReadToEndAsync()
    $errorJob = $process.StandardError.ReadToEndAsync()

    # Wait for the process to exit
    Write-Verbose 'Invoke-Process: Waiting for Process to Exit'
    $process.WaitForExit()
    Write-Verbose "Invoke-Process: Process Exited (ExitCode: $($process.ExitCode))"

    # Get the output from the async operations
    $standardOutput = $outputJob.Result
    $standardError = $errorJob.Result

    # Check for errors
    if ($process.ExitCode) {
        Write-Warning "Invoke-Process: Process Failed`n`tExecutable: $Name`n`tArguments: $Arguments`n`tExit Code: $($process.ExitCode)`n`tError: $standardError"
    }

    # Close the process to free up resources
    $process.Close()
    
    return [PSCustomObject]@{
        Output   = $standardOutput ?? [string]::Empty
        Error    = $standardError ?? [string]::Empty
        ExitCode = $process.ExitCode ?? 0
    }
}