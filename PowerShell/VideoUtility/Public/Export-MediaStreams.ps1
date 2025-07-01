function Export-MediaStreams {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$InputFile,
        [Parameter(Mandatory)]
        [string]$OutputDirectory,
        [Parameter(Mandatory)]
        [ValidateSet('Audio','Subtitle','Video')]
        [string]$Type
    )

    process {
        $inputPath = Resolve-Path $InputFile
        Write-Verbose "InputPath: $($inputPath.Path)"
        Get-MediaStreams -Path $inputPath.Path -Type $Type | ForEach-Object {
            $extension = ".$($_.Index - 1).$($_.CodecName)"
            Write-Verbose "Extension: $extension"
            $outputPath = (Resolve-Path $OutputDirectory).Path, '\', [System.IO.Path]::GetFileNameWithoutExtension($inputFile), $extension -join ''
            Write-Verbose "OutputPath: $outputPath"

            if (Test-Path $outputPath) {
                Write-Host "$Type stream already exists: $outputPath"
                continue
            }

            Write-Host "Exporting $Type stream #$($_.Index - 1) to $outputPath"
            Export-MediaStream -InputPath ($inputPath.Path) -OutputPath $outputPath -Type $Type -Index ($_.Index - 1)
        }
    }
}