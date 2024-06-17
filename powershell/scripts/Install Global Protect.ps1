```powershell
# 1. Check for conection status
# 2. Install Gloabl Protect
# 3. Add Portal Address
# 4. Add connect before Logon
# 5. Remove old certificate
# 6. Add new certificate


#Deploy version 
$RequiredVersion = "1.1.1"

# Deploy MSI package
$MSIPackage = "GlobalProtect64-1.1.1.msi"

# Portal Address
$Address = 'vpn.test.com.au'

# Create the install log file
$InstallLog = "{0}" -f ($MSIPackage -replace '\.msi$', '.log')

# Deploy MSI arguments
$MSIArguments = "/i  `"$PSScriptRoot\$MSIPackage`" /qn /norestart /L*v  `"c:\$InstallLog`" "

$InstallCheck = $false
$AddressCheck = $false
$ConnectBeforeLogonCheck = $false
$CertificateCheck = $false


#Write ScriptLog to csv	
function Write-ScriptLog {
  param (
    [Parameter(Mandatory = $true)]
    [string]$Message,
  
    # Parameter is optional. You can overwite the default value by using Parameter.
    [Parameter(Mandatory = $false)]  
    [string]$CsvFile
  )

  # Check for $CsvFile Parameter
  if (-not $CsvFile) {
    $CsvFile = "c:\" + "{0}" -f ($MSIPackage -replace '\.msi$', '-ScriptLog.csv')
  }

  $Properties = [PSCustomObject]@{
    Timestamp = (Get-Date).ToString("dd-MM-yyyy HH:mm:ss")
    Hostname  = $env:computername
    Message   = $Message
  }
	
  try {
    $Properties | Export-csv -Path $csvFile -NoTypeInformation -Append -ErrorAction Stop
  }
  catch {
    Write-Host "Error appending ScriptError to csv file: $_"
  }
}


#Get adapter properties
$Adapter = Get-NetAdapter | Where-Object { ($_.InterfaceDescription -like "*PANGP*") -and ($_.DriverProvider -like "*PALO*") } `
| Select-Object Name, InterfaceDescription, DriverProvider, Status


#Get installed Version
$InstallVersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect' | Select-Object version -ExpandProperty version -ErrorAction SilentlyContinue


#Global Protect is not connected 
if (-not $adapter -or $adapter.Status -eq "Disabled") {


  #Installed version needs to be updated to match the deployed version.
  if (-not $InstallVersion -or $InstallVersion -lt $RequiredVersion) {
    Write-Host "The installed version ($InstallVersion) must be updated to match the deployed version $($RequiredVersion). Proceed with install"
    $Message = "The installed version ($InstallVersion) must be updated to match the deployed version $($RequiredVersion). Proceed with install"
    $InstallCheck = $true
    Write-ScriptLog -Message $Message
	
    try {
      #Install Software
      $InstallProcess = Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow -verbose -PassThru
      Write-Host "Installing: $($MSIArguments)"
      $Message = "Installing: $($MSIArguments)"
      $InstallCheck = $true
      Write-ScriptLog -Message $Message

      $ExitCode = $InstallProcess.ExitCode
      If ($ExitCode -ne 0) {
        Throw "Failed with exit code $($InstallProcess.ExitCode)."
      }
		
    }
    catch {
      Write-Host "Error occurred during $($MSIPackage) Install: $_"
      $Message = "Error occurred during $($MSIPackage) Install: $_"
      Write-ScriptLog -Message $Message
      exit 1
    }


	
  }
  else {
    Write-Host "Installed version ($InstallVersion) is equal to the deployed version $($RequiredVersion). Installation process terminated."
    $Message = "Installed version ($InstallVersion) is equal to the deployed version $($RequiredVersion). Installation process terminated."
    $InstallCheck = $True
    Write-ScriptLog -Message $Message	
  
  }

}
else {
  Write-Host "Script terminated. The script runs only if Global Protect is not connected."
  $Message = "Script terminated. The script runs only if Global Protect is not connected."
  Write-ScriptLog -Message $Message
  exit 1
}


# Get Portal Address property
$PortalValue = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup' | Select-Object portal -ExpandProperty portal -ErrorAction SilentlyContinue

# Add portal Address
if (-not $PortalValue -or $PortalValue -ne "vpn.test.com.au") {
  try {
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup' -Name 'Portal' -Value $Address -PropertyType String -Force -ErrorAction Stop
    Write-Host "Add portal Address to Global Protect: HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup Name $($Address)"
    $Message = "Add portal Address to Global Protect: HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup Name $($Address)"
    $AddressCheck = $true
    Write-ScriptLog -Message $Message
  }
  catch {
    $AddressCheck = $false
    $Message = "Failed to add Portal Address $($Address) to Global Protect"
    Write-Host "Failed to add Portal Address $($Address) to Global Protect"
    Write-ScriptLog -Message $Message
  }

}
else {
  Write-Host "Portal Address $($PortalValue) is set"
  $Message = "Portal Address $($PortalValue) is set"
  $AddressCheck = $true
  Write-ScriptLog -Message $Message
}


# Get PanPlapProvider property
$PanGPS = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\PLAP Providers\{20A29589-E76A-488B-A520-63582302A285}' | Select-Object '(Default)' -ExpandProperty '(Default)' -ErrorAction SilentlyContinue

# Register PanPlapProvider
if (-not $PanGPS -or $PanGPS -ne "PanPlapProvider") {
  try {
    Start-Process -FilePath "$env:ProgramFiles\Palo Alto Networks\GlobalProtect\PanGPS.exe" -ArgumentList "-registerplap" -Wait -NoNewWindow -verbose -ErrorAction Stop

    #PanPlapProvider takes time to register
    Start-Sleep -Seconds 15

    #Get PanPlapProvider property
    $PanGPS = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\PLAP Providers\{20A29589-E76A-488B-A520-63582302A285}' | Select-Object '(Default)' -ExpandProperty '(Default)' -ErrorAction SilentlyContinue
  
    if ($PanGPS -ne "PanPlapProvider") {
      throw 
    }
    else {
      Write-Host "Set Connect Before Logon registry key value $($PanGPS)"
      $Message = "Set Connect Before Logon registry key value $($PanGPS)"
      $ConnectBeforeLogonCheck = $true
      Write-ScriptLog -Message $Message
    }

  }
  catch {
    $ConnectBeforeLogonCheck = $false
    $Message = "Failed to set Connect Before Logon registry key value ($PanGPS) Register:$_"
    Write-Host "Failed to set Connect Before Logon registry key value ($PanGPS) Register:$_"
    Write-ScriptLog -Message $Message
  }

}
else {
  Write-Host "The Connect Before Logon registry key value $($PanGPS) is set" 
  $Message = "The Connect Before Logon registry key value $($PanGPS) is set"
  $ConnectBeforeLogonCheck = $true
  Write-ScriptLog -Message $Message
}


# Certificate Thumbprint
$OLDCertificate = "CAFCDDE7B9481448DFA1"
$NEWCertificate = "1502B51DB589B3F8FB90" 
 

# Get Certificate property
$Certificate = Get-ChildItem -Path 'Cert:\LocalMachine\My' -ErrorAction SilentlyContinue | Select-Object Subject, Issuer, Thumbprint, FriendlyName, NotBefore, NotAfter  

$NEWCertificateFound = $false

if (-not $Certificate) {
  try {
    Import-PfxCertificate -filepath "$PSScriptRoot\certificate.pfx" -CertStoreLocation 'Cert:\LocalMachine\My' -Password (ConvertTo-SecureString -String 'password' -AsPlainText -Force)
    $CertificateCheck = $true
    $NEWCertificateFound = $true
    $Message = "No Certificates found, Installing New certificate $($NEWCertificate)"
    write-host "No Certificates found, Installing New certificate $($NEWCertificate)"
    Write-ScriptLog -Message $Message
  }
  catch {
    $CertificateCheck = $false
    $Message = "New certificate install $($NEWCertificate) failed"
    Write-Host "New certificate install $($NEWCertificate) failed"
    Write-ScriptLog -Message $Message
  }

}
else {

  # Remove OLD certificate and install new certificate
  foreach ($cert in $Certificate) {
 
    # Remove old certificate  
    if ($OLDCertificate -eq $cert.Thumbprint) {

      Remove-Item -Path "Cert:\LocalMachine\My\$($cert.Thumbprint)"
      $Message = "Removing old certificate $($cert.Thumbprint)"
      write-host "Removing old certificate $($cert.Thumbprint)"
      Write-ScriptLog -Message $Message
    } 


    # Check for NEW certificate  
    if ($NEWCertificate -eq $cert.Thumbprint) {
      $NEWCertificateFound = $true
      $CertificateCheck = $true
      $Message = "New certificate is installed $($NEWCertificate)"
      Write-Host "New certificate is installed $($NEWCertificate)"
      Write-ScriptLog -Message $Message
    }
  }

  # If the new thumbprint does not exist
  if (-not $NEWCertificateFound) {
    try {
      Write-Host "New certificate does not exist. Importing new certificate $($NEWCertificate)"
      Import-PfxCertificate -filepath "$PSScriptRoot\certificate.pfx" -CertStoreLocation 'Cert:\LocalMachine\My' -Password (ConvertTo-SecureString -String 'password' -AsPlainText -Force)
      $CertificateCheck = $true
      $Message = "New Certificate not found. Installing new certificate $($NEWCertificate)"
      Write-Host "New Certificate not found. Installing new certificate $($NEWCertificate)"
      Write-ScriptLog -Message $Message
    }
    catch {
      $CertificateCheck = $false
      $Message = "New certificate install $($NEWCertificate) failed"
      Write-Host "New certificate install $($NEWCertificate) failed"
      Write-ScriptLog -Message $Message
    }


  }
}


# Final checks
if ($InstallCheck -and $AddressCheck -and $ConnectBeforeLogonCheck -and $CertificateCheck -eq $true) {
  Write-Host "Final check with True value equals pass - Install:$($InstallCheck), Address:$($AddressCheck),Connect Before Logon:$($ConnectBeforeLogonCheck), Certificate:$($CertificateCheck)"
  $Message = "Final check with True value equals pass - Install:$($InstallCheck), Address:$($AddressCheck),ConnectBeforeLogon:$($ConnectBeforeLogonCheck), Certificate:$($CertificateCheck)"
  Write-ScriptLog -Message $Message
}
else {
  Write-host "Final check with false value equals failure - Install:$($InstallCheck), Address:$($AddressCheck),Connect Before Logon:$($ConnectBeforeLogonCheck), Certificate:$($CertificateCheck)"
  $Message = "Final check with false value equals failure - Install:$($InstallCheck), Address:$($AddressCheck),Connect Before Logon:$($ConnectBeforeLogonCheck), Certificate:$($CertificateCheck)"
  Write-ScriptLog -Message $Message
  exit 1
}