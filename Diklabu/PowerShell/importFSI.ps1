<#
.Synopsis
   Importiert die Schüler der FSI Klassen in die jeweiligen Kurse.
.DESCRIPTION
   Importiert die Schüler der FSI Klassen in die jeweiligen Kurse. Die XLSX Datei muss folgende Format haben
   "source","destination"
   "FSI14A","TestKurs"
.EXAMPLE
   Import-FSI -xlsx test.xlsx 

#>
function Import-Fsi
{
    [CmdletBinding()]
    Param
    (
        # XLSX Datei
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $xlsx,

        [switch] $force,
        [switch] $whatif
    )

    Begin
    {
        if (Test-Path $xlsx) {
            $data = Import-Excel $xlsx
            if (-not $data[0].source) {
                Write-Error "Keine Spalte mit Namen SOURCE gefunden"
            }
            elseif (-not $data[0].destination) {
                Write-Error "Keine Spalte mit Namen DESTINATION gefunden"
            }
            else {
                foreach ($line in $data) {
                    $klfrom = Find-Course -KNAME $line.source
                    $klto = Find-Course -KNAME $line.destination
                    if (-not $klfrom) {
                        Write-Warning "Klasse $($line.source) nicht gefunden"
                    }
                    elseif (-not $klto) {
                        Write-Warning "Klasse $($line.destination) nicht gefunden!"
                    }
                    else {
                        if (-not $force) {
                            $q=Read-Host "Sollen die Schüler der Klasse $($klfrom.KNAME) zum Kurs $($klto.KNAME) hinzugefügt werden? (J/N)"
                            if ($q -eq "J") {
                                if (-not $whatif) {
                                    Get-Coursemember -id $klfrom.id | Add-Coursemember -klassenid $klto.id
                                }
                                Write-Verbose "Die Schüler der Klasse $($klfrom.KNAME) wurden der Klasse $($klto.KNAME) hinzugefügt."
                            }
                        }
                        else {
                            if (-not $whatif) {
                                Get-Coursemember -id $klfrom.id | Add-Coursemember -klassenid $klto.id
                            }
                            Write-Verbose "Die Schüler der Klasse $($klfrom.KNAME) wurden der Klasse $($klto.KNAME) hinzugefügt."
                        }
                    }
                }
            }

        }
        else {
            Write-Error "Kann Datei $xlsx nicht finden"
        }
    }
}