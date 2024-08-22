```powershell
#Write ScriptLog to csv	
function Write-ScriptLog {
  param (
    [Parameter(Mandatory = $true)]
    [string]$Message,

    [Parameter(Mandatory = $false)]
    [string]$Severity = "INFO",
  
    # Parameter is optional. You can overwite default value by using Parameter.
    [Parameter(Mandatory = $false)]  
    [string]$CsvFile = "$env:SystemDrive\Install-ScriptLog.csv"
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

# Install App
if (-not(Test-Path -Path "${env:ProgramFiles(x86)}\App")) {
 
  try {
      New-Item -Path "${env:ProgramFiles(x86)}" -ItemType Directory -Name "App" | Out-Null
      write-host "Create install directory ProgramFiles (x86)\App" -ForegroundColor Green
      Write-ScriptLog -Message "Create install directory ProgramFiles (x86)\App" -Severity "INFO"

      Copy-Item -Path "$PSScriptRoot\App.exe" -Destination "${env:ProgramFiles(x86)}\App" -erroraction stop
      write-host "Copy App.exe to ProgramFiles (x86)\App" -ForegroundColor Green  
      Write-ScriptLog -Message "Copy App.exe to ProgramFiles (x86)\App" -Severity "INFO"

      Copy-Item -Path "$PSScriptRoot\App.lnk" -Destination "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -erroraction stop
      write-host "Copy App.lnk to start menu" -ForegroundColor Green  
      Write-ScriptLog -Message "Copy App.lnk to start menu" -Severity "INFO"
      exit 0
      }
  catch {
      write-host "Install error $_" -ForegroundColor Red
      Write-ScriptLog -Message "Install error $_" -Severity "ERROR"
      Exit 1
  }

}
else {
  write-host "App is installed" -ForegroundColor Green
  exit 0

}