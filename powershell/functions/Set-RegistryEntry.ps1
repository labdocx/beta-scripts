<#
.SYNOPSIS
Sets a registry entry.

.DESCRIPTION
The Set-RegistryEntry function sets a registry entry at the specified path with the specified name, value, and property type.

.PARAMETER path
The path of the registry entry.

.PARAMETER name
The name of the registry entry.

.PARAMETER value
The value of the registry entry.

.PARAMETER propertyType
The property type of the registry entry. Must be one of "DWORD", "String", "ExpandString", "Binary", "MultiString", "QWord".

.EXAMPLE
Set-RegistryEntry -Path "HKLM:\Software\MyKey" -Name "MyValue" -Value "MyData" -PropertyType "String"

This command sets the registry entry at "HKLM:\Software\MyKey" with the name "MyValue", the value "MyData", and the property type "String".
#>
function Set-registryEntry {
    param (
        [Parameter(Mandatory = $true)]
        [string]$path,
        [Parameter(Mandatory = $true)]
        [string]$name,
        [Parameter(Mandatory = $true)]
        [string]$value,
        [Parameter(Mandatory = $true)]
        [ValidateSet("DWORD", "String", "ExpandString", "Binary", "MultiString", "QWord")]
        [string]$propertyType
    )
    

    switch ($PropertyType) {
        "DWORD" { $Value = [int]$Value }
        # String types need no conversion
        # ExpandString types need no conversion
        "Binary" { $Value = [byte[]][char[]]$Value }
        "MultiString" { $Value = @($Value) }
        "QWord" { $Value = [long]$Value }   
    }

 
  # Check if registry path exists
  if(-not(test-Path $path))
  {
    try {
      New-Item -Path $path -Force -ErrorAction Stop
    }
    catch {
      Write-host "Error creating registry key: $_"
    }
  }


  try
  {
    New-ItemProperty -path $path -name $name -value $value -PropertyType $propertyType -Force -ErrorAction Stop

  }
  catch
  {
    Write-host "Error creating registry property: $_"

  }

}