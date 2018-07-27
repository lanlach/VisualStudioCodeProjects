<#
    .NOTES
    --------------------------------------------------------------------------------
     Created by:  Lachlan Osborne EMIT
     Generated on:       7/26/2018 8:41 AM
     Based on code by:       ianvd's ssccm_v0.5.Package.ps1
    --------------------------------------------------------------------------------
    .DESCRIPTION
        Script for SCCM Task Sequences to convert from BIOS to UEFI, Get computer info, validate service account credentials
        #>
[void][Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
[void][Reflection.Assembly]::Load('System.Data, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
[void][Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][Reflection.Assembly]::Load('System.DirectoryServices, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
Add-Type -AssemblyName 'System.Windows.Forms'
<# Use these to find strong name and paths for Import Assemblies
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms').Location;
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms').FullName;
#>
function Main {
<#
    .SYNOPSIS
        The Main function starts the project application.
    
    .PARAMETER Commandline
        $Commandline contains the complete argument string passed to the script packager executable.
    
    .NOTES
        Use this function to initialize your script and to call GUI forms.
		
    .NOTES
        To get the console output in the Packager (Forms Engine) use: 
		$ConsoleOutput (Type: System.Collections.ArrayList)
#>
	Param ([String]$Commandline)
	
####
	
	# Hide Task Sequence UI
    $TSProgressUI.CloseProgressDialog()
    
    
}

