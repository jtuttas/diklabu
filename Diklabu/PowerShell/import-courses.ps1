<#
.Synopsis
   Importtiert Kurse aus einer CSV Datei
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
        $file,
        [Parameter(Mandatory=$true,                   
                   Position=1)]
        [int]$kategorie

    )
    BEGIN
    {
        $csv = Import-Csv $file
        if ($csv) {
          foreach ($line in $csv) {
            $t=Get-Teacher $line.Dozent
            if ($t) {
              $k=Find-Course -KNAME $line.Kurs
              if ($k) {
                Write-Host "Kurs mit dem Namen"$line.Kurs"existiert bereits" -BackgroundColor DarkGreen
              }
              else {
                New-Course -KNAME $line.Kurs -ID_LEHRER $line.Dozent -ID_KATEGORIE $kategorie -TITEL $line.Titel
              }
            }
            else {
              Write-Host "Lehrer mit Kürzel "$line.Dozent"nicht gefunden" -BackgroundColor DarkRed
              $q = Read-Host "Lehrer Anlegen? (j/n)"
              if ($q -eq "j") {
                $nn = Read-Host "Nachname von "$line.Dozent
                $vn = Read-Host "Vorname von "$line.Dozent
                New-Teacher -ID $line.Dozent -NNAME $nn -VNAME $vn
                New-Course -KNAME $line.Kurs -ID_LEHRER $line.Dozent -ID_KATEGORIE 1 -TITEL $line.Titel
              }
            }
            
          }
        }
        else {
          Write-Host "Kann CSV Datei $file nicht finden!" -BackgroundColor Red
        }
    }
}