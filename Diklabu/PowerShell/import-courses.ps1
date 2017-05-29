<#
.Synopsis
   Importiert Kurse aus einer CSV oder XLSX Datei. Die Datei hat dabei folgende Attribute:
    "ID_KATEGORIE","ID_LEHRER","KNAME","NOTIZ","TITEL"
    "0","TU","WPK_TU_lila","Ein super WPK","Handy Programmierung"
.DESCRIPTION
   Importiert Kurse aus einer CSV Datei. Die Datei hat dabei folgende Attribute:
    "ID_KATEGORIE","ID_LEHRER","KNAME","NOTIZ","TITEL"
    "0","TU","WPK_TU_lila","Ein super WPK","Handy Programmierung"

    Das Encoding sollte auf UTF8 gestellt werden!

    Pflichtparameter sind ID_KATEGORIE,ID_LEHRER,KNAME

    Zulässige Werte f. ID_KATEGORIE
    0 .. normale Klasse
    1 IT_WPK
    2 IT_ENGLISCH
    3 FSI
    4 FOG_WPK
    5 IT-Test
    6 IT-Politik
    7 IT-Deutsch
    8 Religion
    9 IT-CCNA
   10 IT-BSFHR
   11 IT-Sport
   12 BFS-Sport
   13 FOS-Sport 1
   14 Kompakt Sport
   15 FOS-Sport 2
   16 IT Zustatzkurs
   17 Sonderklasse
   18 IT-FK
   19 IT-FKu

    Wird eine Lehrer nicht gefunden, so wird dieser angelegt. Existiert der Kurs bereits, so 
    werden die Attribute aktualisiert.

.EXAMPLE
   Import-Courses -csv "c:\Users\jtutt_000\Seafile\Seafile\Meine Bibliothek\Orga\diklabu_kurse.csv"
.EXAMPLE
   Import-Courses -url https://seafile.mm-bbs.de/f/3a3b68cd62/?raw=1
.EXAMPLE
   Import-Courses -xslx c:\Temp\Klassenliste.xlsx -
#>
function Import-Courses
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
        #XSLX
        [Parameter(Mandatory=$true,                   
                   ParameterSetName=’xlsx‘,
                   Position=0)]
        $xlsx,
        [Parameter(Mandatory=$true,                   
                   ParameterSetName=’xlsx‘,
                   Position=1)]
        $WorkSheetname,
        [switch]$force,
        [switch]$whatif
    )
    BEGIN
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
            $enc = [system.Text.Encoding]::UTF8
            $data = $enc.GetString($p.Content) | ConvertFrom-Csv            
        }
        else {
            $data = Import-Excel $xlsx -WorkSheetname $WorkSheetname
        }
        
        if ((Get-Member -inputobject $data[0] -name "ID_KATEGORIE" -Membertype Properties) -eq "") {
            Write-Error "Im CSV gibt es kein Attribut 'ID_KATEGORIE'!" 
            break;
        }
        if ((Get-Member -inputobject $data[0] -name "ID_LEHRER" -Membertype Properties) -eq "") {
            Write-Error "Im CSV gibt es kein Attribut 'ID_LEHRER'!" 
            break;
        }
        if ((Get-Member -inputobject $data[0] -name "KNAME" -Membertype Properties) -eq "") {
            Write-error "Im CSV gibt es kein Attribut 'KNAME'!" 
            break;
        }
        foreach ($line in $data) {
            $t=Get-Teacher $line.ID_LEHRER
            if ($t) {
                $k=Find-Course -KNAME $line.KNAME
                if ($k) {
                    Write-warning "Kurs mit dem Namen $($line.KNAME) existiert bereits, Attribute werden aktualisiert" 
                    if (-not $whatif) {
                        $r=Set-Course -id $k.id -ID_LEHRER $line.ID_LEHRER -ID_KATEGORIE $line.ID_KATEGORIE -TITEL $line.TITEL -NOTIZ $line.NOTIZ
                        #$r
                    }
                    Write-Verbose "Für den Kurs mit dem Namen $($line.KNAME) wurden die Attribute aktualisiert" 
                }
                else {
                    if (-not $whatif) {
                        $r=New-Course -KNAME $line.KNAME -ID_LEHRER $line.ID_LEHRER -ID_KATEGORIE $line.ID_KATEGORIE -TITEL $line.TITEL -NOTIZ $line.NOTIZ
                    }
                    Write-Verbose "Kurs mit dem Namen $($line.KNAME) angelegt" 
                }
            }
            else {
                Write-Warning "Lehrer mit Kürzel $($line.ID_LEHRER) nicht gefunden" 
                if (-not $force) {
                    $q = Read-Host "Lehrer mit Kürzel $($line.ID_LEHRER) Anlegen? (j/n)"
                    if ($q -eq "j") {
                        $nn = Read-Host "Nachname von "$line.ID_LEHRER
                        $vn = Read-Host "Vorname von "$line.ID_LEHRER
                        if (-not $whatif) {
                            $r=New-Teacher -ID $line.ID_LEHRER -NNAME $nn -VNAME $vn
                        }
                        Write-Verbose "Neuer Lehrer mit Kürzel $($line.Dozent) angelegt"
                        if (-not $whatif) {
                            $r=New-Course -KNAME $line.KNAME -ID_LEHRER $line.ID_LEHRER -ID_KATEGORIE $line.ID_KATEGORIE -TITEL $line.Titel -NOTIZ $line.NOTIZ
                        }
                        Write-Verbose "Kurs mit dem Namen $($line.KNAME) angelegt"
                    }
                }
                else {
                    if (-not $whatif) {
                        $r=New-Teacher -ID $line.ID_LEHRER -NNAME "N.N." -VNAME "N.N."
                    }
                    Write-Verbose "Neuer Lehrer $($line.ID_LEHRER) angelegt" 
                    if (-not $whatif) {
                        $r=New-Course -KNAME $line.KNAME -ID_LEHRER $line.ID_LEHRER -ID_KATEGORIE $line.ID_KATEGORIE -TITEL $line.Titel -NOTIZ $line.NOTIZ
                    }
                    Write-Verbose "Kurs mit dem Namen $($line.KNAME) angelegt"
                }           
            }
        }
    }
}