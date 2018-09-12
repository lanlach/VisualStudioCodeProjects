#I just wanna be able to code shit
$ComputerModel="Precision Tower 323"
#Get-WmiObject -Class Win32_computersystem | Select-Object -ExpandProperty Model
#"Precision Tower 323"
#
Echo $ComputerModel
$BiosCurrentVersion = "2.1.2"
#(Get-WmiObject win32_bios).SMBIOSBIOSVersion
Write-Output $BiosCurrentVersion

$ComputerModelNumber=([regex]::match($ComputerModel,"\s(\w+)$")).Groups[1].Value #grabs last word in a string when word is precede by white space
Write-Output $ComputerModelNumber
#Write-Output $ComputerModelNumber.length
# $BiosVersion=Get-ChildItem $ComputerModel\* -Verbose | Select -ExpandProperty Name| %{[regex]::match($_, "$ComputerModelNumber(.*?)(?:.exe)").Groups[1].Value}
[System.Collections.ArrayList]$BiosVersion= Get-ChildItem $ComputerModel\* -Verbose | Select -ExpandProperty Name| %{[regex]::match($_, "$ComputerModelNumber(?:[-*_*])?(.*?).exe").Groups[1].Value} | Sort-Object 
#"^(?:[^'$ComputerModelNumber']+){1}(.*?).txt").Groups[1].Value}
#included hypen and did not get _2.3.2 "$ComputerModelNumber([^_]*)_?.exe"
#$_, "^(?:[^_]*_){2}(.*?).txt").Groups[1].Value}
#Write-Output $BiosVersion.length
if ($BiosVersion.length-gt 1) {

# foreach($element in $BiosVersion){ if ($element -gt $BiosCurrentVersion){Write-Output $element}
# if ([string]::IsNullOrEmpty($element)) {Write-Output "IS null"
while($BiosVersion -contains ("")){
$BiosVersion.remove("")

}
#($element -eq "")
<#Need to figure out a way to trim the array and then order it appropriately to install the prerequisite BIOS and then mark it to install the next BIOS  #>
}

#}


#Write-Output $BiosVersion.length
#if( %{$BiosVersion -ne $null}) {Write-Output "IS not null"}
Write-Output $BiosVersion
#Write-Output $BiosVersion.IsFixedSize
#Write-Output $BiosVersion.gettype()
