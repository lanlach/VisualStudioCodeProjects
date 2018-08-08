#========================================================================
# Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.1.29
# Created on:   3/8/2014 5:48 PM
# Created by:   Dustin Hedges
# Organization: eBay, Inc.
# Filename:     Invoke-BIOSUpdate.ps1
#========================================================================


<#
	.SYNOPSIS
		A brief description of the Invoke-BIOSUpdate function.

	.DESCRIPTION
		A detailed description of the Invoke-BIOSUpdate function.

	.PARAMETER ComputerName
		LocalHost (Default).  Array, can take input of multiple computer names.

	.PARAMETER  UpdateFile
		The full path to the BIOS Update File.

	.PARAMETER  Arguments
		Optional: Any installation switches required by the update file for silent installation, logging, etc.
		-Arguments = arg1,arg2,arg3

	.EXAMPLE
		PS C:\> Invoke-BIOSUpdate -UpdateFile 'C:\Temp\BIOS_10.exe' -Arguments /s,/l="C:\Temp\BIOSUpdate.log"
		This example shows how to call the Invoke-BIOSUpdate function with named parameters.

	.EXAMPLE
		PS C:\> Invoke-BIOSUpdate 'C:\Temp\BIOS_10.exe' /Silent,/l="C:\Temp\BIOSUpdate.log"
		This example shows how to call the Invoke-BIOSUpdate function with positional parameters.

	.INPUTS
		System.String,System.String[]

	.OUTPUTS
		System.Int32
#>
[CmdletBinding()]
param(
	[Parameter(Position=1, Mandatory=$true, HelpMessage="Full file path to BIOS Update File",
	ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	[String]$UpdateFile,
	
	[Parameter(Position=2, Mandatory=$false, HelpMessage="Installation Arguments",
	ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
	[System.String[]]$Arguments
)
begin
{
	# Validate File Path
	if(-Not(Test-Path $UpdateFile)){
		Write-Verbose "File not found at $UpdateFile"
		Exit 1
	}
		
	# Define Full Path to Script Directory if file path starts with '.\'
	if($UpdateFile.StartsWith(".\")){
		$scriptDirectory = Split-Path ($MyInvocation.MyCommand.Path) -Parent
		$UpdateFile = $UpdateFile.Replace(".\", "$ScriptDirectory\")
		Write-Verbose "Updating BIOS using file: $UpdateFile"
	}
}
process {
	# Process Local Computer
	Try{
		switch ($(Get-WmiObject -Namespace "root\CIMV2\Security\MicrosoftVolumeEncryption" -Class Win32_EncryptableVolume -ErrorAction 'Stop' | Where-Object {$_.DriveLetter -eq $env:SystemDrive}).GetConversionStatus().ConversionStatus) {
			{1..5} {
				#BitLocker is currently enabled, disable protectors
				Write-Verbose "BitLocker is currently enabled.  Disabling Protectors"
				$manageBDE = "$env:windir\System32\manage-bde.exe"
				$result = Start-Process -FilePath $manageBDE -ArgumentList "-protectors -disable $($env:SystemDrive)" -NoNewWindow -Wait -ErrorAction SilentlyContinue -PassThru
				Write-Verbose "Manage-BDE Return Code $($result.ExitCode)"
				#& $manageBDE "-protectors -disable $($env:SystemDrive)" | Out-Null
				#New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "BitLocker" -Value "manage-bde.exe -protectors -enable $($env:SystemDrive)" -Force | Out-Null
				Write-Verbose "Setting RunOnce Key to re-enable BitLocker Protectors"
				New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "BitLocker" -Value "manage-bde.exe -protectors -enable $($env:SystemDrive)" -Force | Out-Null
				break;
			}
			default {
				# Drive not encrypted with BitLocker.  No further action required.
				break;
			}
		}		
			
	}
	Catch{
		$e = $_.Exception
		Write-Verbose $e
		break;
	}
	
	# Execute BIOS Update File
	$processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
	$processStartInfo.FileName = "$UpdateFile"
	$processStartInfo.UseShellExecute = $false
	$processStartInfo.RedirectStandardOutput = $true
	$processStartInfo.RedirectStandardError = $true
	if ($Arguments.Length -gt 0)
	{
		$processStartInfo.Arguments = $Arguments
	}
	$processStartInfo.WindowStyle = 'Hidden'
	
	Write-Verbose "Starting BIOS Update Execution"
	$process = [System.Diagnostics.Process]::Start($processStartInfo)
	
	$stdOut = $process.StandardOutput.ReadToEnd() -replace "`0", ""
	$stdErr = $process.StandardError.ReadToEnd() -replace "`0", ""
	
	$process.WaitForExit()
	Write-Verbose "Exit Code: $($process.ExitCode)"
	return $process.ExitCode
}
end {
}
