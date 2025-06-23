@{
    IncludeDefaultRules = $true
    Rules = @{
        # Code Style and Formatting
        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind = 'space'
        }
        
        PSUseConsistentNaming = @{
            Enable = $true
        }
        
        # Variable and Function Usage
        PSUseDeclaredVarsMoreThanAssignments = @{
            Enable = $true
        }
        
        PSUseSingularNouns = @{
            Enable = $true
        }
        
        # Output and Logging
        PSAvoidUsingWriteHost = @{
            Enable = $true
        }
        
        PSUseWriteOutput = @{
            Enable = $true
        }
        
        # Function Design
        PSUseShouldProcessForStateChangingFunctions = @{
            Enable = $true
        }
        
        PSUseSupportsShouldProcess = @{
            Enable = $true
        }
        
        # Parameter Design and Error Handling
        PSUseShouldContinueForStateChangingFunctions = @{
            Enable = $true
        }
        
        # Performance
        PSAvoidUsingCmdletAliases = @{
            Enable = $true
        }
        
        PSAvoidUsingPositionalParameters = @{
            Enable = $true
        }
        
        # Security
        PSAvoidUsingInvokeExpression = @{
            Enable = $true
        }
        
        PSAvoidUsingPlainTextForPassword = @{
            Enable = $true
        }
        
        # Best Practices
        PSUseCompatibleCommands = @{
            Enable = $true
        }
        
        PSUseCompatibleSyntax = @{
            Enable = $true
        }
        
        # Documentation
        PSUseUTF8EncodingForHelpFile = @{
            Enable = $true
        }
        
        PSUseBOMForUnicodeEncodedFile = @{
            Enable = $true
        }
        
        PSAvoidUsingWMICmdlet = @{
            Enable = $true  # WMI might be needed for system operations
        }
        
        PSAvoidUsingEmptyCatchBlock = @{
            Enable = $true  # Some error handling might be intentional
        }
        
        # Disable some rules that might not be appropriate for this project
        PSAvoidGlobalVars = @{
            Enable = $false  # Module-level variables are acceptable
        }
    }
} 