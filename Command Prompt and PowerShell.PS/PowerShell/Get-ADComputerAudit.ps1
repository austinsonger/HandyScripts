<#
.Synopsis
    Gets a list of Computer Objects in the supplied domain, including if they're online (pingable).
.DESCRIPTION
    This script uses the ActiveDirectory module to get a list of all computer objects (optionally filtered).
    It will also add an Online boolean attribute showing if the Computer is pingable or not.
.PARAMETER Domain
    A String specifying the domain you'd like to audit
.PARAMETER Filter
    A standard Filter to reduce the Computer Objects returned. By default all Computers object will be returned/
.EXAMPLE
    ./Get-ADComputerAudit mycompany.com
.EXAMPLE
    ./Get-ADComputerAudit -Domain mycompany.com -Filter "{cn -like "WIN*"}"
.NOTES
  Version:        1.1
  Author:         Cameron McConnochie
  Creation Date:  8 Aug 2018
  Purpose/Change: Added some progress information

  Version:        1.0
  Author:         Cameron McConnochie
  Creation Date:  26 July 2018
  Purpose/Change: Initial script development
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$Domain,

    [Parameter(Mandatory=$False)]
    [string]$filter = "*"
)

Import-Module ActiveDirectory

$rtn = $null
Write-Progress -Activity "Gathering Computer account information..." -Status "Getting Object List" -PercentComplete 0
#Build the list of Computer Objects, adding the Online Attribute
$output = Get-ADComputer -Server $Domain -Filter * -Properties * | Sort-Object lastlogontimestamp | Select-Object cn,dnshostname, operatingSystem, operatingSystemServicePack, operatingSystemVersion, whenCreated, Online, @{n='lastLogonTimestamp';e={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}

#Test a connection to each Computer and set the Online value
Write-Progress -Activity "Gathering Computer account information..." -Status "Testing Connections" -PercentComplete 30
For( $i = 0; $i -lt $output.count; $i++) {
    $rtn = Test-Connection -CN $output[$i].dnshostname -Count 1 -BufferSize 16 -Quiet

    IF($rtn -match 'True') {
        $output[$i].Online = $true
    } ELSE {
        $output[$i].Online = $false
    }
}

#Return the resulting output
Write-Progress -Activity "Gathering Computer account information..." -Status "Done" -PercentComplete 100
Return $output