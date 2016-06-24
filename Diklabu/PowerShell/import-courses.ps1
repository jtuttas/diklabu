<#
.Synopsis
   Importiert Kurse aus einer CSV Datei. Die Datei hat dabei folgende Attribute:
   Kurs,Dozent,Kategorie,Titel
   IT15_Eng_EK_rot_A2_1-2,EK,2,Englisch-WPK Niveau A2
.DESCRIPTION
   Importtiert Kurse aus einer CSV Datei
.EXAMPLE
   Import-Courses -csv Klassenliste.csv -kategorie 1
#>
function Import-Courses
{
    Param
    (
        # Hilfebeschreibung zu Param1
        [Parameter(Mandatory=$true,                   
                   Position=0)]
        $csv,

        [switch]$force,
        [switch]$whatif

    )
    BEGIN
    {
        $data = Import-Csv $csv
        if ((Get-Member -inputobject $data[0] -name "Kurs" -Membertype Properties) -eq "") {
            Write-Host "Im CSV gibt es kein Attribut 'Kurs'!" -BackgroundColor DarkRed
            break;
        }
        if ((Get-Member -inputobject $data[0] -name "Dozent" -Membertype Properties) -eq "") {
            Write-Host "Im CSV gibt es kein Attribut 'Dozent'!" -BackgroundColor DarkRed
            break;
        }
        if ((Get-Member -inputobject $data[0] -name "Kategorie" -Membertype Properties) -eq "") {
            Write-Host "Im CSV gibt es kein Attribut 'Kategorie'!" -BackgroundColor DarkRed
            break;
        }
        if ((Get-Member -inputobject $data[0] -name "Titel" -Membertype Properties) -eq "") {
            Write-Host "Im CSV gibt es kein Attribut 'Titel'!" -BackgroundColor DarkRed
            break;
        }
        if ($data) {
          foreach ($line in $data) {
            $t=Get-Teacher $line.Dozent
            if ($t) {
              $k=Find-Course -KNAME $line.Kurs
              if ($k) {
                Write-Host "Kurs mit dem Namen"$line.Kurs"existiert bereits" -BackgroundColor DarkGreen
              }
              else {
                if (-not $whatif) {
                    New-Course -KNAME $line.Kurs -ID_LEHRER $line.Dozent -ID_KATEGORIE $line.Kategorie -TITEL $line.Titel
                }
                Write-Host "Kurs mit dem Namen"$line.Kurs"angelegt" -BackgroundColor DarkRed
              }
            }
            else {
              Write-Host "Lehrer mit Kürzel "$line.Dozent"nicht gefunden" -BackgroundColor DarkRed
              if (-not $force) {
                  $q = Read-Host "Lehrer Anlegen? (j/n)"
                  if ($q -eq "j") {
                    $nn = Read-Host "Nachname von "$line.Dozent
                    $vn = Read-Host "Vorname von "$line.Dozent
                    if (-not $whatif) {
                        $r=New-Teacher -ID $line.Dozent -NNAME $nn -VNAME $vn
                    }
                    Write-Host "Neuer Lehrer "$line.Dozent"angelegt" -BackgroundColor DarkRed
                    if (-not $whatif) {
                        $r=New-Course -KNAME $line.Kurs -ID_LEHRER $line.Dozent -ID_KATEGORIE 1 -TITEL $line.Titel
                    }
                    Write-Host "Kurs mit dem Namen"$line.Kurs"angelegt" -BackgroundColor DarkRed
                  }
              }
              else {
                    if (-not $whatif) {
                        $r=New-Teacher -ID $line.Dozent -NNAME "N.N." -VNAME "N.N."
                    }
                    Write-Host "Neuer Lehrer "$line.Dozent"angelegt" -BackgroundColor DarkRed
                    if (-not $whatif) {
                        $r=New-Course -KNAME $line.Kurs -ID_LEHRER $line.Dozent -ID_KATEGORIE 1 -TITEL $line.Titel
                    }
                    Write-Host "Kurs mit dem Namen"$line.Kurs"angelegt" -BackgroundColor DarkRed
              }
            }
            
          }
        }
        else {
          Write-Host "Kann CSV Datei $file nicht finden!" -BackgroundColor Red
        }
    }
}