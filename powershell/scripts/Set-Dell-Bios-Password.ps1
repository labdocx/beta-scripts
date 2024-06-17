```powershell
<#
This PowerShell script offers a streamlined approach to resetting the BIOS password on Dell systems. 
It leverages the DellBIOSProvider module to interact with the BIOS directly from the Windows environment, 
providing a simplified, command-line driven process.  

Before execution, ensure the DellBIOSProvider PowerShell module is downloaded. 
This module is essential for the script to communicate with the BIOS. 
It should be placed in the same directory as the script.


#>

# Passwords
$OldPasswords = @("password1", "password2", "password3")
$NewPassword = "password3"
$success = $false


#Write ScriptLog to csv	
function Write-ScriptLog {
  param (
    [Parameter(Mandatory = $true)]
    [string]$Message,

    [Parameter(Mandatory = $false)]
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

# Powershell Module
if (-not (Test-Path -Path "$env:ProgramFiles\WindowsPowerShell\Modules\DellBIOSProvider")) {
  Copy-Item -Path "$PSScriptRoot\DellBIOSProvider\" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\DellBIOSProvider" -Recurse -Force
  Write-Host "Copying Powershell Module to $env:ProgramFiles\WindowsPowerShell\Modules\DellBIOSProvider"
  Write-ScriptLog -Message "Copying Powershell Module to $env:ProgramFiles\WindowsPowerShell\Modules\DellBIOSProvider" -Severity "INFO"
    
}

 
try {

  if ((get-module -Name DellBIOSProvider | Select-Object name -ExpandProperty name) -eq "DellBIOSProvider") {
  
    Write-Host "The Dell BIOS Provider module is loaded."
    Write-ScriptLog -Message "The Dell BIOS Provider module is loaded." -Severity "INFO"  
  }  
  else {
    Import-Module "DellBIOSProvider" -Force -Verbose -ErrorAction Stop  
    Write-ScriptLog -Message "The Dell BIOS Provider module is loaded." -Severity "INFO"
  }
}  

    
catch {
        
  Write-Host "Error importing module: $_"
  Write-ScriptLog -Message "Error importing module: $_" -Severity "ERROR"
  exit 1
     
}
       
# Current Bios Password
$currentPassword = Get-Item -Path "DellSmbios:\Security\IsAdminPasswordSet" | Select-Object -Property CurrentValue -ExpandProperty CurrentValue -ErrorAction SilentlyContinue


# if no password    
if ($currentPassword -eq "false") {
  Write-Host "Blank password set to $NewPassword"
  Set-Item "DellSmbios:\Security\AdminPassword" -value $NewPassword 
  Write-ScriptLog -Message "Blank password set to new password $NewPassword" -Severity "INFO"
      
  break  # Exit the loop if successful
      
}
else {

  foreach ($OldPassword in $OldPasswords) {

    try {
          
      Set-Item -Path "DellSmbios:\Security\AdminPassword" -Value $NewPassword -Password $OldPassword -ErrorAction Stop
      Write-Host "New Password set to $NewPassword using old password $OldPassword"
      write-scriptlog -Message "New Password set using old password $OldPassword" -Severity "INFO"
      $success = $true

      break  # Exit the loop if successful
                      
    }
    catch {
        
      Write-Host "Failed to change password with password $OldPassword"
      Write-ScriptLog -Message "Failed to change password with password $OldPassword" -Severity "WARNING"
      # Failed to change password with this password, try the next one            
    }
  }
}
     

# All password change attempts failed    
if (-not $success) {
  Write-Host "All password change attempts failed."        
  write-scriptlog -Message "All password change attempts failed." -Severity  "WARNING"
}
