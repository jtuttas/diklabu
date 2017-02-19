<#
.Synopsis
   Importiert Schüler aus einer CSV Datei 
.DESCRIPTION
   Importiert Schüler aus einer CSV Datei. Die CSV Datei hat dabei folgende
   Struktur:
   
    "GEBDAT","NNAME","VNAME"
    1968-04-11,"Tuttas","Jörg",
    1968-04-11,"Tuttas","Joerg"
    1968-04-11,"Tuttas","Frank"

    Notwendige Attribute sind GEBDAT, NNAME und VNAME!
    
    Das Encoding sollte auf UTF8 gestellt werden!

    Wird der Schüler gefunden, so werden seine Attribute aktualisiert.

.EXAMPLE
   import-pupils -csv "c:\Users\jtutt_000\Seafile\Seafile\Meine Bibliothek\Orga\diklabu_schueler.csv" 
.EXAMPLE
   import-pupils -url https://seafile.mm-bbs.de/f/0864d0fa50/?raw=1
.EXAMPLE
   import-pupils -url https://seafile.mm-bbs.de/f/0864d0fa50/?raw=1 | Add-Coursemember -klassenid 45
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
        else {
            $p=Invoke-WebRequest $url 
            $enc = [system.Text.Encoding]::UTF8;
            $data = $enc.GetString($p.Content) | ConvertFrom-Csv
            
        }
        
        if ((Get-Member -inputobject $data[0] -name "GEBDAT" -Membertype Properties) -eq "") {
            Write-Error "Im CSV gibt es kein Attribut 'GEBDAT'!" 
            break;
        }
        if ((Get-Member -inputobject $data[0] -name "NNAME" -Membertype Properties) -eq "") {
            Write-Error "Im CSV gibt es kein Attribut 'NNAME'!" 
            break;
        }
        if ((Get-Member -inputobject $data[0] -name "VNAME" -Membertype Properties) -eq "") {
            Write-error "Im CSV gibt es kein Attribut 'VNAME'!" 
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
            $p
        }
    }
}