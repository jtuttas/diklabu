<#
.Synopsis
   Importiert Schüler aus einer CSV Datei und weist ihnen ggf. eine Klasse zu
.DESCRIPTION
   Importiert Schüler aus einer CSV Datei. Die CSV Datei hat dabei folgende
   Struktur:
   
    "GEBDAT","NNAME","VNAME","KNAME"
    1968-04-11,"Tuttas","Jörg",""
    1968-04-11,"Tuttas","Joerg","FIAE17A"
    1968-04-11,"Tuttas","Frank",""

    Notwendige Attribute sind GEBDAT, NNAME und VNAME! Optional ist KNAME, wird KNAME angegeben, wird der Schüler gleichzeitig in die 
    Klasse eingetragen
    
    Das Encoding sollte auf UTF8 gestellt werden!

    Wird der Schüler gefunden, so werden seine Attribute aktualisiert.

.EXAMPLE
   import-pupils -csv "c:\Users\jtutt_000\Seafile\Seafile\Meine Bibliothek\Orga\diklabu_schueler.csv" 
.EXAMPLE
   import-pupils -url https://seafile.mm-bbs.de/f/0864d0fa50/?raw=1
.EXAMPLE
   import-pupils -url https://seafile.mm-bbs.de/f/0864d0fa50/?raw=1 | Add-Coursemember -klassenid 45
   Legt die Schüler an und weist Sie der Klasse mit dem ID 45 zu

.EXAMPLE
   import-pupils -xlsx c:\Temp\schueler.xlsx | Add-Coursemember -klassenid 45
   Legt die Schüler an und weist Sie der Klasse mit dem ID 45 zu

#>
function Import-Pupils
{
    [CmdletBinding()]
    Param
    (
        #CSV Datei
        [Parameter(Mandatory=$true,                   
                   ParameterSetName=’csv‘,
                   Position=0)]
        $csv,

        #Seafile URL
        [Parameter(Mandatory=$true,                   
                   ParameterSetName=’seafile‘,
                   Position=0)]
        $url,
        #XLSX Datei
        [Parameter(Mandatory=$true,                   
                   ParameterSetName=’excel‘,
                   Position=0)]
        $xlsx,
        [switch]$force,
        [switch]$whatif
    )

    Begin
    {
        if ($csv) {
            if (Test-Path $csv) {
                $data = Import-Csv $csv
            }
            else {
                Write-Error "CSV Datei $csv not found !";
                break;
            }
        }
        elseif ($url) {
            $p=Invoke-WebRequest $url 
            $enc = [system.Text.Encoding]::UTF8;
            $data = $enc.GetString($p.Content) | ConvertFrom-Csv
            
        }
        elseif ($xlsx) {
            if (Test-Path $xlsx) {
                $data = Import-Excel $xlsx
                foreach ($d in $data) {
                    $d.GEBDAT = (Get-Date (Get-DAte -Year 1899 -Day 30 -Month 12 -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays($d.GEBDAT) -Format yyyy-MM-dd)
                }
            }
            else {
                Write-Error "XLSX Datei $xlsx not found !";
                break;
            }
        }
        
        if ((Get-Member -inputobject $data[0] -name "GEBDAT" -Membertype Properties) -eq "") {
            Write-Error "Es kein Attribut 'GEBDAT'!" 
            break;
        }
        if ((Get-Member -inputobject $data[0] -name "NNAME" -Membertype Properties) -eq "") {
            Write-Error "Es kein Attribut 'NNAME'!" 
            break;
        }
        if ((Get-Member -inputobject $data[0] -name "VNAME" -Membertype Properties) -eq "") {
            Write-error "Es kein Attribut 'VNAME'!" 
            break;
        }
    }
    Process {
        foreach ($line in $data) {
            $p = Find-Pupil -VNAME $line.VNAME -NNAME $line.NNAME -GEBDAT $line.GEBDAT             
            if ($p) {
                Write-Warning "Schüler $($line.VNAME) $($line.NNAME) [$($line.GEBDAT)] gefunden! Attribute werden aktuialisiert!"
                if (-not $force) {
                    $q = Read-Host ("Attribute des Schülers aktualisieren? (J/N)")
                    if ($q -eq "j") {
                        if (-not $whatif) {
                            $p=Set-Pupil -id $p.id -VNAME $line.VNAME -NNAME $line.NNAME -GEBDAT $line.GEBDAT -EMAIL $line.EMAIL
                        }
                    }
                }
                else {
                    if (-not $whatif) {
                        $p=Set-Pupil -id $p.id -VNAME $line.VNAME -NNAME $line.NNAME -GEBDAT $line.GEBDAT -EMAIL $line.EMAIL
                    }
                }
            }
            else {
                if (-not $whatif) {
                    $p=New-Pupil -VNAME $line.VNAME -NNAME $line.NNAME -GEBDAT $line.GEBDAT -EMAIL $line.EMAIL 
                }
                Write-Verbose "Neuer Schüler $($line.VNAME) $($line.NNAME) [$($line.GEBDAT)] angelegt"
            }
            
            $pu=Get-Pupil -id $p.id
            $kl=$pu.klassen | Where-Object {$_.ID_KATEGORIE -eq 0}
            if ($kl) {
                Write-Verbose "Schüler $($line.VNAME) $($line.NNAME) ist bereits in Klasse $($kl.KNAME) und wird dort entfernt!"
                if (-not $force) {
                    $q=Read-Host "Soll der Schüler aus der Klasse $($kl.KNAME) entfernt werden (J/N)"
                    if ($q -eq "J") {
                        if (-not $whatif) {
                            $r=Remove-Coursemember -id $p.id -klassenid $kl.id 
                        }
                    }
                }
                else {
                    if (-not $whatif) {
                        $r=Remove-Coursemember -id $p.id -klassenid $kl.id 
                    }
                }
            }
            if ($line.KNAME) {
                $kl = Find-Course -KNAME $line.KNAME
                if (-not $kl) {
                    Write-Verbose "Klasse $($line.KNAME) nicht gefunden! Wird angelegt!"
                    if (-not $force) {
                        $q=Read-Host "Soll die Klasse $($line.KNAME) angelegt werden? (J/N)"
                        if ($q -eq "J") {
                            if (-not $whatif) {
                                $kl=New-Course -KNAME $line.KNAME -ID_KATEGORIE 0
                            }
                        }
                    }
                    else {
                        if (-not $whatif) {
                            $kl=New-Course -KNAME $line.KNAME -ID_KATEGORIE 0
                        }
                    }
                }
                if ($kl) {
                    Write-Verbose "Schüler $($line.VNAME) $($line.NNAME) in Klasse $($kl.KNAME) hinzufügen"
                    if (-not $force) {
                        $q=Read-Host "Soll der Schüler  $($line.VNAME) $($line.NNAME) zu Klasse $($kl.KNAME) hinzugefügt wreden (J/N)"
                        if ($q -eq "J") {
                            if (-not $whatif) {
                                $a= Add-Coursemember -id $p.id -klassenid $kl.id 
                            }
                        }
                    }
                    else {
                        if (-not $whatif) {
                            $a=Add-Coursemember -id $p.id -klassenid $kl.id 
                        }
                    }
                }
            }
        }
    }
}