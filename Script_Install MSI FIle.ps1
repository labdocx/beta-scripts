
# MSI package
$MSIPackage = "installer.msi"

# Install log file
$InstallLog = "{0}" -f ($MSIPackage -replace '\.msi$', '.log')


# Create log file if it does not exist
if(-not(Test-Path c:\$InstallLog)){

new-item -ItemType file -Path c:\$InstallLog
}


# MSI arguments 
$MSIArguments = "/i  `"$PSScriptRoot\$MSIPackage`" /qn  /norestart /L*v `"c:\$InstallLog`" " 

try {
# Install MSI package
Write-Host "Installing $($MSIPackage)..." -ForegroundColor green
$InstallProcess = Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -Verb Runas -verbose -PassThru
      
      # Check exit code
      $ExitCode = $InstallProcess.ExitCode
      If ($ExitCode -ne 0) {
        Throw "Failed with exit code $($InstallProcess.ExitCode)."
      }	

}  catch {
      Write-Host "Error occurred during $($MSIPackage) Install: $_" -ForegroundColor green
      exit 1
    }