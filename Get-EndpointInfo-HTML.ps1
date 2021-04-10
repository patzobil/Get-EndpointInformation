. .\functions\Write-Progress.ps1
$script:steps = ([System.Management.Automation.PsParser]::Tokenize((Get-Content "$PSScriptRoot\Get-EndpointInfo-HTML.ps1$($MyInvocation.MyCommand.Name)"), [ref]$null) | Where-Object { $_.Type -eq 'Command' -and $_.Content -eq 'Write-ProgressHelper' }).Count
$stepCounter = 0

#region FilePaths
#* ************************************** PATHS ***************************************
$exportLocation = "$env:USERPROFILE\Desktop\exports"
# $exportLocation = "$PSScriptRoot\exports"
$cssBaseFolder = "$PSScriptRoot\css"
$cssFinalFolder = "$exportLocation\css"

$cssBaseLocation = "$cssBaseFolder\style.css"
$cssFinalLocation= "$cssFinalFolder\style.css"

#* Check the exportLocation exists, if not create it before proceeding!
try {
    if (-not(Test-Path $exportLocation -ErrorAction Stop)){
        try {
            New-Item $exportLocation -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Output $_.Exception
        }
    }
}
catch {
    Write-Output $_.Exception
    # $cssFinalLocation = $cssBaseLocation

}
#! ************************************** PATHS ***************************************
#endregion

#region MODULES
#* ************************************** MODULES ***************************************
Write-ProgressHelper "Getting Date & Time" -StepNumber ($stepCounter++)
. .\modules\DateTime.ps1
Write-ProgressHelper "Getting Computer Name" -StepNumber ($stepCounter++)
. .\modules\Hostname.ps1
Write-ProgressHelper "Getting Last Boot Time" -StepNumber ($stepCounter++)
. .\modules\LastBootInfo.ps1
Write-ProgressHelper "Getting OS Info" -StepNumber ($stepCounter++)
. .\modules\OSInfo.ps1
Write-ProgressHelper "Getting PowerShell Version Table" -StepNumber ($stepCounter++)
. .\modules\PSVersionTable.ps1
Write-ProgressHelper "Getting Chipset Info" -StepNumber ($stepCounter++)
. .\modules\ChipsetInfo.ps1
Write-ProgressHelper "Getting BIOS Info" -StepNumber ($stepCounter++)
. .\modules\BIOSInfo.ps1
Write-ProgressHelper "Getting Disk Info" -StepNumber ($stepCounter++)
. .\modules\LogicalDisks.ps1
Write-ProgressHelper "Getting NIC Info" -StepNumber ($stepCounter++)
. .\modules\NetworkAdapters.ps1
Write-ProgressHelper "Getting Hosts File Info" -StepNumber ($stepCounter++)
. .\modules\HostsFile.ps1
Write-ProgressHelper "Getting Application Info" -StepNumber ($stepCounter++)
. .\modules\ApplicationsInfo.ps1
Write-ProgressHelper "Getting Services Info" -StepNumber ($stepCounter++)
. .\modules\WindowsServices.ps1
#! ************************************** MODULES ***************************************
#endregion

# $transcriptLocation = "$env:USERPROFILE\Desktop\exports\$env:computername-$fileDate-Console Transcript.txt"
# Start-Transcript $transcriptLocation -IncludeInvocationHeader -NoClobber
# Start-Transcript $transcriptLocation -Append


#region Get-PublicIP
#* ************************************** Get-PublicIP Function ***************************************
Write-ProgressHelper "Getting Public IP Address" -StepNumber ($stepCounter++)
. .\functions\Get-PublicIP.ps1
$publicIP = Get-PublicIP
#! ************************************** Get-PublicIP Function ***************************************
#endregion

#region HTML tags
#* ************************************** HTML TAGS ***************************************
Write-ProgressHelper "Creating HTML Head" -StepNumber ($stepCounter++)
. .\html\HTMLHead.ps1
Write-ProgressHelper "Creating the Header" -StepNumber ($stepCounter++)
. .\html\TopHeader.ps1
Write-ProgressHelper "Creating the Side Navigation Bar" -StepNumber ($stepCounter++)
. .\html\SideNavigationBar.ps1
Write-ProgressHelper "Creating SearchForms" -StepNumber ($stepCounter++)
. .\html\SearchForms.ps1
Write-ProgressHelper "Adding a BackToTop Button" -StepNumber ($stepCounter++)
. .\html\TopButton.ps1
#! ************************************** HTML TAGS ***************************************
#endregion

#region BuildHTML
#* ************************************** BUILD HTML ***************************************
$HTML =`
 ConvertTo-HTML -Body " $topHeader $sideNavigation $BiosInfo $ProcessorInfo $OSinfo $PSversion $diskArray $NetAdapterInfo $hostsInfo $searchScripts $AppInfo $ServicesInfo $topButton"`
 -Head $header -Title "Computer Information Report"`
 -PostContent "<p id='Footer'>Report generated by $env:USERNAME at $footerDate   |   Public IP Address: $publicIP</p>"
#! ************************************** BUILD HTML ***************************************
#$Title $bootInfo $sideNavigation $topHeader
#endregion

#region ExportHTML
#* ************************************** EXPORT HTML ***************************************
$HTMLExportLocation = "$exportLocation\$env:computername-$fileDate-Report.html"
# $ZIPArchive = "$exportLocation\$env:computername-$fileDate-Report.zip"

#* Generate HTML File
try {
    $HTML | Out-File $HTMLExportLocation -Encoding ascii -ErrorAction Stop
}
catch [System.IO.DirectoryNotFoundException]{
    #Remove the Write-Output because when running in EXE you will have errors...
    # Write-Output $_.Exception
    try {
        New-Item $exportLocation -ItemType Directory -ErrorAction Stop
        $HTML | Out-File $HTMLExportLocation -Encoding ascii -ErrorAction Stop
    }
    catch {
        Write-Output $_.Exception
    }
}
#! ************************************** EXPORT HTML ***************************************


#* OPEN HTML FILE ON BROWSER AFTER COLLECTION
Invoke-Item $HTMLExportLocation
#endregion


#* ************************************** COMPRESS / ARCHIVE ***************************************
# Compress-Archive $HTMLExportLocation -DestinationPath $ZIPArchive
#! ************************************** COMPRESS / ARCHIVE ***************************************

#* ************************************** SHOW WIN10 NOTIFICATION ***************************************
. .\functions\Show-Notification.ps1
Show-Notification "Script Get-PCInfo-HTML complete, please find the exported file at $HTMLExportLocation"
#! ************************************** SHOW WIN10 NOTIFICATION ***************************************

# Stop-Transcript

# PAUSE