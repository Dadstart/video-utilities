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

    Write-Verbose "Invoke-Process: STARTING - Name: $Name"
    Write-Verbose "Invoke-Process: Arguments: $($Arguments -join ' ')"
 
    try {
        # Set up process start info
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $Name
        $psi.Arguments = $Arguments -join ' '
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        
        # Create process object
        $proc = [System.Diagnostics.Process]::new()
        $proc.StartInfo = $psi

        # Start the process
        $proc = [System.Diagnostics.Process]::Start($psi)

        # Read both streams (these block until the process exits or streams close)
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()

        Write-Verbose 'Invoke-Process: process.WaitForExit()'
        $proc.WaitForExit()
        Write-Verbose "Invoke-Process: Process exited with code $($proc.ExitCode)"

        # Check for errors
        $exitCode = $proc.ExitCode
        if ($exitCode -ne 0) {
            Write-Warning "Invoke-Process: Process Failed`n`tExecutable: $Name`n`tArguments: $($psi.Arguments)`n`tExit Code: $exitCode`n`tError: $stderr"
        }

        # Close the process to free up resources
        Write-Verbose 'Invoke-Process: Closing Process'
        $proc.Close()
        Write-Verbose 'Invoke-Process: Process Closed'

        $result = [PSCustomObject]@{
            Output   = $stdout
            Error    = $stderr
            ExitCode = $exitCode
        }

        return $result
    }
    catch {
        Write-Verbose 'Invoke-Process: Exception'
        Write-Verbose "Invoke-Process: Error: $($_)"
        Write-Verbose "Invoke-Process: Message: $($_.Exception.Message)"
        Write-Verbose "Invoke-Process: FullyQualifiedErrorId: $($_.FullyQualifiedErrorId)"
        Write-Verbose "Invoke-Process: ScriptStackTrace: $($_.ScriptStackTrace)"
        Write-Verbose "Invoke-Process: CategoryInfo: $($_.CategoryInfo)"
        throw $_
    }
}