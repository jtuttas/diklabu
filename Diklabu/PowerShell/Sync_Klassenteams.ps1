<#
.Synopsis
   Sync-Klassenteams
.DESCRIPTION
   Sync-Klassenteams
.EXAMPLE
   Sync-Klassenteams -csv untis.csv
#>
function Sync-Klassenteams
{
    [CmdletBinding()]
    Param
    (
        # CSV Datei
        [Parameter(Mandatory=$true,
                   Position=0)]
        $csv,
        # Searchbase
        [Parameter(Position=1)]
        $searchbase="OU=Klassenteams,OU=Schüler,DC=mmbbs,DC=local"

    )

    Begin
    {
        if (Test-Path $csv) {
            . "$PSScriptRoot/gpu2ADGroups.ps1"
            . "$PSScriptRoot/sync_ldapTeacherGroups.ps1"
            try {
                $obj=Import-Untis -path $csv
                Sync-LDAPTeams -map $obj -Verbose -force -searchbase $searchbase  
            }
            catch {
                Write-Error "Es ist ein Fehler aufgetreten"
            }
        }
        else {
            Write-Error "CSV Datei $csv nicht gefunden!"
        }
    }
}