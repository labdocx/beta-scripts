<#
.SYNOPSIS
Writes a log message to a CSV file.

.DESCRIPTION
The Write-ScriptLog function writes a log message with a timestamp, hostname, and severity to a CSV file. The CSV file is located at the system drive root by default, but this can be changed with the CsvFile parameter.

.PARAMETER Message
The log message to write to the CSV file.

.PARAMETER Severity
The severity of the log message. Must be one of "INFO", "WARNING", "ERROR". Defaults to "INFO" if not specified.

.PARAMETER CsvFile
The path of the CSV file to write the log message to. Defaults to "$env:SystemDrive\ScriptLog.csv" if not specified.

.EXAMPLE
Write-ScriptLog -Message "This is a test log message" -Severity "INFO"

This command writes a log message with the message "This is a test log message" and the severity "INFO" to the default CSV file.
#>

#Write ScriptLog to csv	
function Write-ScriptLog {
 [CmdletBinding()]
  
  param (
    [Parameter(Mandatory = $true)]
    [string]$Message,

    [Parameter(Mandatory = $false)]
    [ValidateSet("INFO", "WARNING", "ERROR")]
    [string]$Severity = "INFO",
  
    # Parameter is optional. You can overwite default value by using Parameter.
    [Parameter(Mandatory = $false)]  
    [string]$CsvFile = "$env:SystemDrive\ScriptLog.csv"
  )


  $Properties = [PSCustomObject]@{
    Timestamp = (Get-Date).ToString("dd-MM-yyyy HH:mm:ss")
    Hostname  = $env:computername
    Severity  = $Severity
    Message   = $Message
  }
	
  try {
    $Properties | Export-csv -Path $csvFile -NoTypeInformation -Append -ErrorAction Stop
  }
  catch {
    Write-Host "Error appending ScriptLog to csv file: $_"
  }
}
