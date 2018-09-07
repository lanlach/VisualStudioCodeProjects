#I just wanna be able to code shit
$ComputerModel="Precision Tower 323"
#Get-WmiObject -Class Win32_computersystem | Select-Object -ExpandProperty Model
#"Precision Tower 323"
#
Echo $ComputerModel
$BiosCurrentVersion = (Get-WmiObject win32_bios).SMBIOSBIOSVersion

$ComputerModelNumber=([regex]::match($ComputerModel,"\s(\w+)$")).Groups[1].Value #grabs last word in a string when word is precede by white space
Write-Output $ComputerModelNumber
Write-Output $ComputerModelNumber.length
# $BiosVersion=Get-ChildItem $ComputerModel\* -Verbose | Select -ExpandProperty Name| %{[regex]::match($_, "$ComputerModelNumber(.*?)(?:.exe)").Groups[1].Value}
$BiosVersion= Get-ChildItem $ComputerModel\* -Verbose | Select -ExpandProperty Name| %{[regex]::match($_, "$ComputerModelNumber(?:[-*_*])?(.*?).exe").Groups[1].Value}
#"^(?:[^'$ComputerModelNumber']+){1}(.*?).txt").Groups[1].Value}
#included hypen and did not get _2.3.2 "$ComputerModelNumber([^_]*)_?.exe"
#$_, "^(?:[^_]*_){2}(.*?).txt").Groups[1].Value}
if ($BiosVersion.length-gt 1) {
foreach($element in $BiosVersion){ if ($element -gt $BiosCurrentVersion){Write-Output $element}
if ([string]::IsNullOrEmpty($element)) {Write-Output "IS null"}
#($element -eq "")

}
}
Write-Output $BiosVersion.length
#if( %{$BiosVersion -ne $null}) {Write-Output "IS not null"}
Write-Output $BiosVersion
Write-Output $BiosVersion.IsFixedSize
#Write-Output $BiosVersion.gettype()
