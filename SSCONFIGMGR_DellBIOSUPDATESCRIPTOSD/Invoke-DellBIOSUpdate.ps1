# // ***************************************************************************
# // 
# // Author:	Dustin Hedges
# //
# // File:      Invoke-DellBIOSUpdate.ps1
# // 
# // Version:   2.0
# // 
# // Purpose:   Used to determine if a BIOS Update is required based on model
# //			and available BIOS Updates downloaded to specific folder structure.
# //
# // Changes:	2012_05_22 - Added additional loops to detect multiple required BIOS updates
# //			2012_05_22 - Added switch condition to allow for oddly-named BIOS versions (i.e. OptiPlex 745)
# //			2012_05_23 - Added custom conditions for model-specific operations (i.e. Required BIOS Patches)
# //			2012_06_04 - Converted $BIOSReleaseDate to Universal Time to avoid issues with different time zones/locals.
# //
# // Comment:	Folder structure required is as follows:
# // 			<folder root>
# //				|_<model>
# //					|_<BIOS Update Files>
# //
# // Assumptions:	This script assumes that all BIOS Update Files are named so that the files are ordered
# //				from smallest revision to largest revision number (i.e. Oldest to Newest)
# // ***************************************************************************

function Invoke-BIOSUpdate {
	[CmdletBinding()]
	[OutputType([System.String])]
	param(
		[Parameter(ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String[]]
		$File,
		
		[Parameter(ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String[]]
		$Arguments
	)
	begin {
		Write-Host "BIOS Update Needed.  Attempting BIOS Flash Operation..."
		Write-Host "BIOS Update File: $File"
		Write-Host "BIOS Update Arguments: $Arguments`n"
	}
	process {
		try {
			$install = [System.Diagnostics.Process]::Start($File,$Arguments)
			$install.WaitForExit() | Out-Null
			Write-Host "Restarting System"
			Stop-Transcript
			Restart-Computer -Force
		} catch {[Exception]
			Write-Host "Failed: $_"
		}
	}
	end {}
}

$logPath = "$env:WINDIR\Dell_BIOS_Update.log"

#Start the Logging
Start-Transcript $logPath -Append

Write-Host "Starting Dell BIOS Update Operation"

#Get system information
$ScriptFolder = $PWD.Path
$Reboot = $false
$Model = $((Get-WmiObject -Class Win32_ComputerSystem).Model).Trim()

#Get BIOS Information from WMI
$BIOS = Get-WmiObject -Namespace root\CIMV2 -Class Win32_BIOS
$BIOSVersion = $BIOS.SMBIOSBIOSVersion

#Get BIOS Release Date & Converto to Universal Time to avoid issues with timezone and formatting
$BIOSVersionReleaseDate = $($BIOS.ConvertToDateTime($BIOS.ReleaseDate)).ToUniversalTime()

Write-Host "System Model: $Model"
Write-Host "Installed BIOS Version: $BIOSVersion`n"

if(Test-Path -Path $ScriptFolder\$model)
{
	#Get our collection of available update files for the current model
	$BIOSUpdateFiles = Get-ChildItem -Path $ScriptFolder\$Model
	foreach($BIOSUpdateFile in $BIOSUpdateFiles){
	
		#Strip off the file extension
		$BIOSUpdateFileVersion = $BIOSUpdateFile.ToString() -replace ($BIOSUpdateFile.Extension,"")
		
		#Get the actual BIOS Update File Version from the file name
		switch ($Model) {
			"OptiPlex 745" {$BIOSUpdateFileVersion = $BIOSUpdateFileVersion.Substring($BIOSUpdateFileVersion.Length -5)}
			default {$BIOSUpdateFileVersion = $BIOSUpdateFileVersion.Substring($BIOSUpdateFileVersion.Length -3)}
		}
		
		Write-Host "Available BIOS File: $BIOSUpdateFile"
		Write-Host "Available BIOS Version: $BIOSUpdateFileVersion`n"
		
		#Check specific systems to see if they require a BIOS "Patch"
		switch ($Model) {
			"Latitude E6410" {	if(($BIOSVersion -eq "A01") -and ($BIOSVersionReleaseDate -ne "5/26/2010")){
								Invoke-BIOSUpdate "$ScriptFolder\$Model\E6410P02.exe" "-noreboot -nopause -forceit"}
								if(($BIOSVersion -eq "A01") -and ($BIOSUpdateFileVersion -eq "5/26/2010")){
								Invoke-BIOSUpdate "$ScriptFolder\$Model\$BIOSUpdateFile" "-noreboot -nopause -forceit"}
				break
			}
			"Latitude E6510" {	if(($BIOSVersion -eq "A01") -and ($BIOSVersionReleaseDate -ne "5/26/2010")){
								Invoke-BIOSUpdate "$ScriptFolder\$Model\E6510P02.exe" "-noreboot -nopause -forceit"}
								if(($BIOSVersion -eq "A01") -and ($BIOSUpdateFileVersion -eq "5/26/2010")){
								Invoke-BIOSUpdate "$ScriptFolder\$Model\$BIOSUpdateFile" "-noreboot -nopause -forceit"}
				break
			}
			default {
				break
			}
		}
		
		#Compare the BIOS File Version with the currently installed version to determine next steps
		switch ($BIOSVersion.CompareTo($BIOSUpdateFileVersion)) {
			0 {
				Write-Host "BIOS Version is up to date`n"
				break
			}
			1 {
				Write-Host "BIOS Version is newer than supplied BIOS version`n"
				break
			}
			default {
				#Run BIOS Update if it's not a Patch BIOS Update since this was handled earlier
				if(!($BIOSUpdateFileVersion -like "P*")){
					Invoke-BIOSUpdate "$ScriptFolder\$Model\$BIOSUpdateFile" "-noreboot -nopause -forceit"}
				else{Write-Host "Skipping BIOS Patch $BIOSUpdateFileVersion`n"}
				break	
			}
		}
	}	Write-Host "End Dell BIOS Update Operation`n"
		Stop-Transcript -ErrorAction SilentlyContinue
}
else
{
	Write-Host "Model Not Supported`n"
	Stop-Transcript -ErrorAction SilentlyContinue
}